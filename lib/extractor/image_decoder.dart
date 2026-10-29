import 'dart:typed_data';

class MmfImage {
  int handle = 0;
  int width = 0;
  int height = 0;
  int graphicMode = 0;
  int flags = 0;
  int hotspotX = 0;
  int hotspotY = 0;
  int actionPointX = 0;
  int actionPointY = 0;
  Uint8List transparentColor = Uint8List(4);
  Uint8List data = Uint8List(0);

  bool flag(int bit) => (flags >> bit) & 1 == 1;
  bool get alpha => flag(4);
  bool get rgba => flag(7);
}

class ImageDecodeInfo {
  final double fusion;
  final int build;
  final bool plus;
  final bool premultipliedAlpha;

  const ImageDecodeInfo({
    required this.fusion,
    required this.build,
    this.plus = false,
    this.premultipliedAlpha = false,
  });
}

int _padding(MmfImage img, ImageDecodeInfo info) {
  var colorModeSize = 3;
  var modSize = 2;
  switch (img.graphicMode) {
    case 3:
      colorModeSize = 1;
      modSize = 4;
    case 6:
    case 7:
      colorModeSize = 2;
    case 0:
    case 8:
      colorModeSize = 4;
  }
  if (!img.flag(2) || info.plus || info.fusion < 2.0) {
    return img.width * colorModeSize % modSize;
  }
  if (info.build < 280) {
    return img.width * colorModeSize % modSize * colorModeSize;
  }
  return img.width % modSize * colorModeSize;
}

int _alphaPadding(MmfImage img) => (4 - (img.width % 4)) % 4;

Uint8List decodeImage(MmfImage img, ImageDecodeInfo info,
    [Uint8List? palette]) {
  switch (img.graphicMode) {
    case 3:
      if (palette == null) {
        throw UnsupportedError('graphic mode 3 requires a frame palette');
      }
      return _paletteToRgba(img, palette);
    case 4:
      return _normal24ToRgba(img, info);
    case 6:
      return _normal15ToRgba(img, info);
    case 7:
      return _normal16ToRgba(img, info);
    case 8:
      return _bpp32ToRgba(img, info);
    default:
      throw UnsupportedError('graphic mode ${img.graphicMode} unsupported');
  }
}

class _RleState {
  int command = 0;
  bool rleLoop = false;
  bool rleCommander = false;
  bool active;

  _RleState(MmfImage img)
      : active = img.flag(0) || img.flag(1) || img.flag(2);

  bool get shouldRead => !active || !rleLoop || rleCommander;
}

void _rleAdvance(MmfImage img, _RleState s, _Pos p) {
  if (!s.active) return;
  if (--s.command != 0) return;
  s.command = img.data[p.v++];
  s.rleCommander = false;
  s.rleLoop = false;
  if (s.command > 128) {
    s.command -= 128;
    s.rleCommander = true;
  } else if (s.command == 0) {
    s.rleLoop = true;
  }
}

class _Pos {
  int v = 0;
}

_Pos _rleInit(MmfImage img, _RleState s) {
  final p = _Pos();
  if (!s.active) return p;
  s.command = img.data[p.v];
  if (s.command > 128) {
    s.command -= 128;
    s.rleCommander = true;
  } else if (s.command == 0) {
    s.rleLoop = true;
  }
  p.v++;
  return p;
}

void _alphaTail(MmfImage img, Uint8List out, _Pos p) {
  final aPad = _alphaPadding(img);
  for (var y = 0; y < img.height; y++) {
    for (var x = 0; x < img.width; x++) {
      out[(y * img.width + x) * 4 + 3] = img.data[p.v++];
    }
    p.v += aPad;
  }
}

Uint8List _normal24ToRgba(MmfImage img, ImageDecodeInfo info) {
  final out = Uint8List(img.width * img.height * 4);
  final pad = _padding(img, info);
  final rle = _RleState(img);
  final p = _rleInit(img, rle);
  var r = 0, g = 0, b = 0;
  for (var y = 0; y < img.height; y++) {
    for (var x = 0; x < img.width; x++) {
      if (rle.shouldRead) {
        r = img.data[p.v++];
        g = img.data[p.v++];
        b = img.data[p.v++];
        rle.rleLoop = true;
      }
      final o = (y * img.width + x) * 4;
      out[o] = b;
      out[o + 1] = g;
      out[o + 2] = r;
      out[o + 3] = 255;
      if (!img.alpha &&
          r == img.transparentColor[2] &&
          g == img.transparentColor[1] &&
          b == img.transparentColor[0]) {
        out[o + 3] = 0;
      }
      _rleAdvance(img, rle, p);
    }
    p.v += pad * 3;
  }
  if (img.alpha) _alphaTail(img, out, p);
  return out;
}

Uint8List _normal16ToRgba(MmfImage img, ImageDecodeInfo info) {
  final out = Uint8List(img.width * img.height * 4);
  final pad = _padding(img, info);
  final rle = _RleState(img);
  final p = _rleInit(img, rle);
  var r = 0, g = 0, b = 0;
  for (var y = 0; y < img.height; y++) {
    for (var x = 0; x < img.width; x++) {
      if (rle.shouldRead) {
        final v = img.data[p.v++] | (img.data[p.v++] << 8);
        r = ((v & 63488) >> 11) << 3;
        g = ((v & 2016) >> 5) << 2;
        b = (v & 31) << 3;
        rle.rleLoop = true;
      }
      final o = (y * img.width + x) * 4;
      out[o] = r;
      out[o + 1] = g;
      out[o + 2] = b;
      out[o + 3] = 255;
      if (!img.alpha &&
          r == img.transparentColor[0] &&
          g == img.transparentColor[1] &&
          b == img.transparentColor[2]) {
        out[o + 3] = 0;
      }
      _rleAdvance(img, rle, p);
    }
    p.v += pad * 2;
  }
  if (img.alpha) _alphaTail(img, out, p);
  return out;
}

Uint8List _normal15ToRgba(MmfImage img, ImageDecodeInfo info) {
  final out = Uint8List(img.width * img.height * 4);
  final pad = _padding(img, info);
  final rle = _RleState(img);
  final p = _rleInit(img, rle);
  var r = 0, g = 0, b = 0;
  for (var y = 0; y < img.height; y++) {
    for (var x = 0; x < img.width; x++) {
      if (rle.shouldRead) {
        final v = img.data[p.v++] | (img.data[p.v++] << 8);
        r = ((v & 31744) >> 10) << 3;
        g = ((v & 992) >> 5) << 3;
        b = (v & 31) << 3;
        rle.rleLoop = true;
      }
      final o = (y * img.width + x) * 4;
      out[o] = r;
      out[o + 1] = g;
      out[o + 2] = b;
      out[o + 3] = 255;
      if (!img.alpha &&
          r == img.transparentColor[0] &&
          g == img.transparentColor[1] &&
          b == img.transparentColor[2]) {
        out[o + 3] = 0;
      }
      _rleAdvance(img, rle, p);
    }
    p.v += pad;
  }
  if (img.alpha) _alphaTail(img, out, p);
  return out;
}

Uint8List _bpp32ToRgba(MmfImage img, ImageDecodeInfo info) {
  final out = Uint8List(img.width * img.height * 4);
  final pad = _padding(img, info);
  var position = 0;
  for (var y = 0; y < img.height; y++) {
    for (var x = 0; x < img.width; x++) {
      final o = (y * img.width + x) * 4;
      out[o] = img.data[position + 2];
      out[o + 1] = img.data[position + 1];
      out[o + 2] = img.data[position];
      out[o + 3] = 255;
      if (img.alpha || img.rgba) {
        out[o + 3] = img.data[position + 3];
      } else if (img.data[o + 2] == img.transparentColor[0] &&
          img.data[o + 1] == img.transparentColor[1] &&
          img.data[o] == img.transparentColor[2]) {
        out[o + 3] = 0;
      }
      position += 4;
    }
    position += pad * 4;
  }
  if (position == img.data.length) return out;
  if (img.alpha && !img.rgba) _alphaTail(img, out, _Pos()..v = position);
  return out;
}

Uint8List _paletteToRgba(MmfImage img, Uint8List palette) {
  final out = Uint8List(img.width * img.height * 4);
  final rle = _RleState(img);
  final p = _rleInit(img, rle);
  final pixelCount = img.width * img.height;
  final extraBytes = img.data.length - pixelCount;
  var padPerRow = 0;
  if (!rle.active && extraBytes > 0 && extraBytes % img.height == 0) {
    padPerRow = extraBytes ~/ img.height;
  }
  var r = 255, g = 255, b = 255;
  for (var y = 0; y < img.height; y++) {
    for (var x = 0; x < img.width; x++) {
      if (rle.shouldRead) {
        final idx = img.data[p.v++];
        r = palette[idx * 4];
        g = palette[idx * 4 + 1];
        b = palette[idx * 4 + 2];
        rle.rleLoop = true;
      }
      final o = (y * img.width + x) * 4;
      out[o] = r;
      out[o + 1] = g;
      out[o + 2] = b;
      out[o + 3] = 255;
      if (!img.alpha &&
          r == img.transparentColor[0] &&
          g == img.transparentColor[1] &&
          b == img.transparentColor[2]) {
        out[o + 3] = 0;
      }
      _rleAdvance(img, rle, p);
    }
    p.v += padPerRow;
  }
  if (img.alpha) _alphaTail(img, out, p);
  return out;
}
