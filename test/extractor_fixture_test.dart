import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnaf_flutter/extractor/byte_reader.dart';
import 'package:fnaf_flutter/extractor/decompress.dart';
import 'package:fnaf_flutter/extractor/image_decoder.dart';
import 'package:fnaf_flutter/extractor/mmf_extractor.dart';
import 'package:fnaf_flutter/assets/asset_store.dart';

void w16(BytesBuilder b, int v) {
  b.addByte(v & 0xFF);
  b.addByte((v >> 8) & 0xFF);
}

void w32(BytesBuilder b, int v) {
  for (var i = 0; i < 4; i++) {
    b.addByte((v >> (8 * i)) & 0xFF);
  }
}

Uint8List z(Uint8List d) =>
    Uint8List.fromList(const ZLibEncoder().encode(d));

Uint8List yuni(String s) {
  final b = BytesBuilder();
  for (final c in s.codeUnits) {
    w16(b, c);
  }
  w16(b, 0);
  return b.toBytes();
}

Uint8List imageRecord(int handle, int w, int h, int mode, int flags,
    Uint8List pixels) {
  final inner = BytesBuilder();
  w32(inner, 0);
  w32(inner, 0);
  w32(inner, pixels.length);
  w16(inner, w);
  w16(inner, h);
  inner.addByte(mode);
  inner.addByte(flags);
  w16(inner, 0);
  w16(inner, 1);
  w16(inner, 2);
  w16(inner, 3);
  w16(inner, 4);
  inner.add(Uint8List.fromList([255, 0, 0, 0]));
  if ((flags >> 3) & 1 == 1) {
    final comp = z(pixels);
    w32(inner, comp.length);
    inner.add(comp);
  } else {
    inner.add(pixels);
  }
  final b = BytesBuilder();
  w32(b, handle);
  w32(b, 0);
  final comp = z(inner.toBytes());
  w32(b, comp.length);
  b.add(comp);
  return b.toBytes();
}

Uint8List imageRecord25Plus(int handle, Uint8List lz4, int decompSize) {
  final b = BytesBuilder();
  w32(b, handle);
  w32(b, 0);
  w32(b, 0);
  w32(b, 0);
  w32(b, lz4.length + 4);
  w16(b, 1);
  w16(b, 1);
  b.addByte(8);
  b.addByte(0);
  w16(b, 0);
  w16(b, 0);
  w16(b, 0);
  w16(b, 0);
  w16(b, 0);
  b.add(Uint8List(4));
  w32(b, decompSize);
  b.add(lz4);
  return b.toBytes();
}

Uint8List chunk(int id, int flag, Uint8List data) {
  final b = BytesBuilder();
  w16(b, id);
  w16(b, flag);
  if (flag == 1) {
    final comp = z(data);
    w32(b, comp.length + 8);
    w32(b, data.length);
    w32(b, comp.length);
    b.add(comp);
  } else {
    w32(b, data.length);
    b.add(data);
  }
  return b.toBytes();
}

Uint8List packEntry(String name, Uint8List data, bool compressed) {
  final b = BytesBuilder();
  final n = yuni(name).sublist(0, name.length * 2);
  w16(b, name.length);
  b.add(n);
  w32(b, 0);
  final payload = compressed ? z(data) : data;
  if (compressed) {
    payload[0] = 0x78;
    payload[1] = 0xDA;
  }
  w32(b, payload.length);
  b.add(payload);
  return b.toBytes();
}

Uint8List soundEntry(int handle, String name, Uint8List wav,
    {bool fromDisk = false, bool unicode = true}) {
  final b = BytesBuilder();
  w32(b, handle);
  w32(b, 0);
  w32(b, 0);
  final nameBytes = unicode
      ? yuni(name)
      : Uint8List.fromList([...utf8.encode(name), 0]);
  final nameLen = name.length;
  final body = BytesBuilder()..add(nameBytes)..add(wav);
  if (fromDisk) {
    final raw = body.toBytes();
    w32(b, raw.length);
    w32(b, 0x20);
  } else {
    w32(b, body.toBytes().length);
    w32(b, 0);
  }
  w32(b, 44100);
  w32(b, nameLen + 1);
  if (!fromDisk) {
    final comp = z(body.toBytes());
    w32(b, comp.length);
    b.add(comp);
  } else {
    b.add(body.toBytes());
  }
  return b.toBytes();
}

Uint8List buildExe({
  int runtimeVersion = 770,
  int productVersion = 3,
  int build = 284,
  String header = 'PAMU',
  bool unicode = true,
  bool withPacks = true,
  bool optimize = false,
  bool reloc = false,
  int nameFlag = 0,
  bool noPalette = false,
  bool flag2Name = false,
  bool paletteCompressed = false,
  int fileTail = 0,
}) {
  final data = BytesBuilder();
  if (withPacks) {
    w32(data, 0x77777777);
    data.add(Uint8List(24));
    w32(data, 2);
    data.add(packEntry('a.mfx', Uint8List.fromList([9, 8, 7]), true));
    data.add(packEntry('b.dll', Uint8List.fromList([5, 6]), false));
  }
  data.add(Uint8List.fromList(ascii.encode(header)));
  w16(data, runtimeVersion);
  w16(data, 0);
  w32(data, productVersion);
  w32(data, build);
  data.add(chunk(0x2224, flag2Name ? 2 : nameFlag,
      unicode
          ? yuni('Test Game')
          : Uint8List.fromList(utf8.encode('Test Game\x00'))));
  final ext = BytesBuilder()..add(Uint8List(8))..add(Uint8List.fromList([optimize ? 0x00 : 0, optimize ? 0x02 : 0, 0, 0]));
  data.add(chunk(0x2245, 0, ext.toBytes()));
  if (noPalette) {
    data.add(chunk(0x3333, 0, chunk(0x7F7F, 0, Uint8List(0))));
  } else {
    final frame = BytesBuilder()
      ..add(chunk(0x3337, paletteCompressed ? 1 : 0, () {
        final p = BytesBuilder();
        w16(p, 0);
        w16(p, 2);
        p.add(Uint8List.fromList([10, 20, 30, 0, 40, 50, 60, 0]));
        return p.toBytes();
      }()))
      ..add(chunk(0x7F7F, 0, Uint8List(0)));
    data.add(chunk(0x3333, 0, frame.toBytes()));
  }

  final bank = BytesBuilder();
  if (optimize) {
    w32(bank, 1);
    bank.add(imageRecord25Plus(
        7, Uint8List.fromList([0x40, 66, 66, 66, 66]), 4));
  } else {
    w32(bank, 3);
    bank.add(imageRecord(5, 1, 1, 4, 0, Uint8List.fromList([10, 20, 30])));
    bank.add(imageRecord(
        6, 1, 1, 4, 8, Uint8List.fromList([10, 20, 30])));
    bank.add(imageRecord(
        7, 1, 1, 8, 0, Uint8List.fromList([10, 20, 30, 40])));
  }
  data.add(chunk(0x6666, 0, bank.toBytes()));

  final sb = BytesBuilder();
  w32(sb, 2);
  sb.add(soundEntry(3, 'boom', Uint8List.fromList([1, 2, 3, 4]),
      unicode: unicode));
  sb.add(soundEntry(4, 'disk', Uint8List.fromList([5, 6]),
      fromDisk: true, unicode: unicode));
  data.add(chunk(0x6668, 0, sb.toBytes()));
  data.add(chunk(0x7F7F, 0, Uint8List(0)));

  const sectionStart = 0x400;
  final body = data.toBytes();
  final b = BytesBuilder();
  b.add(Uint8List.fromList(ascii.encode('MZ')));
  b.add(Uint8List(58));
  w16(b, 0x80);
  while (b.length < 0x80) {
    b.addByte(0);
  }
  b.add(Uint8List.fromList([0x50, 0x45, 0, 0]));
  w16(b, 0x14C);
  w16(b, reloc ? 2 : 1);
  b.add(Uint8List(240));
  if (reloc) {
    b.add(Uint8List.fromList(Uint8List.fromList([46, 116, 101, 120, 116, 0, 0, 0])));
    b.add(Uint8List(8));
    w32(b, sectionStart);
    w32(b, 0x10);
    b.add(Uint8List(16));
    b.add(Uint8List.fromList(Uint8List.fromList([46, 114, 101, 108, 111, 99, 0, 0])));
    b.add(Uint8List(8));
    w32(b, sectionStart + 0x40);
    w32(b, 0x10);
    b.add(Uint8List(16));
    while (b.length < sectionStart + 0x50) {
      b.addByte(0);
    }
    b.add(body);
    while (b.length < sectionStart + 0x50 + body.length) {
      b.addByte(0);
    }
    while (b.length < 0x850) {
      b.addByte(0);
    }
  } else {
    b.add(Uint8List.fromList(Uint8List.fromList([46, 116, 101, 120, 116, 0, 0, 0])));
    b.add(Uint8List(8));
    w32(b, sectionStart);
    w32(b, 0x10);
    b.add(Uint8List(16));
    while (b.length < sectionStart + 0x10) {
      b.addByte(0);
    }
    b.add(body);
  }
  b.add(Uint8List(fileTail));
  return b.toBytes();
}

void main() {
  test('full exe extraction', () {
    final g = MmfExtractor.extract(buildExe());
    expect(g.appName, 'Test Game');
    expect(g.build, 284);
    expect(g.fusion, 2.0);
    expect(g.images.length, 3);
    expect(g.sounds.length, 2);
    expect(g.packFiles.length, 2);
    expect(g.packFiles[0].data, [9, 8, 7]);
    expect(g.packFiles[1].data, [5, 6]);
    expect(g.framePalette, isNotNull);
    expect(g.imageRgba(g.images[4]!).length, 4);
    expect(g.sounds[0].name, 'boom');
    expect(g.sounds[0].frequency, 44100);
    expect(g.sounds[0].data, [1, 2, 3, 4]);
    expect(g.sounds[1].name, 'disk');
  });

  test('PAME ascii + fusion 1.5', () {
    final g = MmfExtractor.extract(
        buildExe(header: 'PAME', unicode: false, runtimeVersion: 769));
    expect(g.fusion, 1.5);
    expect(g.appName, 'Test Game');
    expect(g.sounds[0].name, 'boom');
  });

  test('fusion 2.1 optimized images', () {
    final g = MmfExtractor.extract(buildExe(
        build: 270, productVersion: 1, optimize: true));
    expect(g.fusion, 2.1);
    expect(g.images[6]!.graphicMode, 8);
  });

  test('build 270 fusion 2.0 no product', () {
    final g = MmfExtractor.extract(buildExe(build: 270, productVersion: 0));
    expect(g.fusion, 2.0);
  });

  test('no pack data header', () {
    final g = MmfExtractor.extract(buildExe(withPacks: false));
    expect(g.packFiles, isEmpty);
  });

  test('reloc fallback', () {
    final g = MmfExtractor.extract(buildExe(reloc: true));
    expect(g.appName, 'Test Game');
  });

  test('compressed palette frame', () {
    final g = MmfExtractor.extract(buildExe(paletteCompressed: true));
    expect(g.framePalette, [10, 20, 30, 0, 40, 50, 60, 0]);
  });

  test('bad headers throw', () {
    expect(() => MmfExtractor.extract(Uint8List(64)),
        throwsA(isA<MmfExtractException>()));
    final bad = BytesBuilder();
    bad.add(Uint8List.fromList([0x4D, 0x5A]));
    bad.add(Uint8List(58));
    w16(bad, 0x80);
    bad.add(Uint8List(0x80 - bad.length));
    bad.add(Uint8List.fromList([0x50, 0x45, 0, 0]));
    w16(bad, 0x14C);
    w16(bad, 1);
    bad.add(Uint8List(240));
    bad.add(Uint8List.fromList(Uint8List.fromList([46, 116, 101, 120, 116, 0, 0, 0])));
    bad.add(Uint8List(8));
    w32(bad, 0x400);
    w32(bad, 8);
    bad.add(Uint8List(16));
    while (bad.length < 0x400) {
      bad.addByte(0);
    }
    w32(bad, 0xDEAD);
    expect(() => MmfExtractor.extract(bad.toBytes()),
        throwsA(isA<MmfExtractException>()));

    final bad2 = buildExe(withPacks: false).sublist(0, 0x400);
    final bad3 = BytesBuilder()..add(bad2)..add(Uint8List.fromList([1, 2, 3, 4]));
    expect(() => MmfExtractor.extract(bad3.toBytes()),
        throwsA(isA<MmfExtractException>()));
  });

  test('asset store end to end', () {
    var progress = 0.0;
    final store = AssetExtractor.extract(buildExe(),
        onProgress: (p) => progress = p);
    expect(store.appName, 'Test Game');
    expect(store.images.length, 3);
    expect(store.sounds['boom'], [1, 2, 3, 4]);
    expect(store.sound('missing'), isNull);
    expect(store.image(4), isNotNull);
    expect(store.image(999), isNull);
    expect(progress, 1.0);
  });

  test('byte reader helpers', () {
    final b = BytesBuilder();
    w16(b, 'h'.codeUnitAt(0));
    w16(b, 'i'.codeUnitAt(0));
    w16(b, 0);
    final r = ByteReader(b.toBytes());
    expect(r.readYunicode(), 'hi');
    expect(r.position, 6);
    expect(r.done, true);

    final r2 = ByteReader(yuni('ab'));
    expect(r2.readYuniversalStop(2), 'ab');
    final r3 = ByteReader(yuni('aX'));
    expect(r3.readYuniversal(1), 'a');
    final r4 = ByteReader(Uint8List.fromList([97, 0, 98]));
    expect(r4.readAsciiStop(3), 'a');
    final r5 = ByteReader(Uint8List.fromList([0xFF, 0xFF]), 0, 2);
    expect(r5.readShort(), -1);
    final r6 = ByteReader(Uint8List.fromList([0xFF, 0xFF]));
    expect(r6.peekShort(), -1);
    final r7 = ByteReader(Uint8List.fromList([9]));
    expect(r7.readByte(), 9);
    expect(() => ByteReader(Uint8List(2)).skip(9), throwsRangeError);
  });

  test('decompress all branches', () {
    expect(isZlib(Uint8List(0)), false);
    expect(isZlib(Uint8List.fromList([1])), false);
    expect(isZlib(Uint8List.fromList([0x79, 0x9C])), false);
    for (final s in [0x01, 0x5E, 0x9C, 0xDA]) {
      expect(isZlib(Uint8List.fromList([0x78, s])), true);
    }
    final raw = Uint8List.fromList(Deflate(Uint8List.fromList([5, 5, 5])).getBytes());
    expect(decompressBlock(raw), [5, 5, 5]);

    final lits = <int>[0xF0, 0x02, for (var i = 0; i < 17; i++) i];
    expect(lz4Decompress(Uint8List.fromList(lits), 17).length, 17);
    final lits2 = <int>[0xF0, 0xFF, 0x02, for (var i = 0; i < 272; i++) i % 256];
    expect(lz4Decompress(Uint8List.fromList(lits2), 272).length, 272);
    final match = Uint8List.fromList([0x1F, 9, 0x01, 0x00, 0x05]);
    final om = lz4Decompress(match, 25);
    expect(om[0], 9);
    expect(om[24], 9);
  });

  test('image decode modes', () {
    const info = ImageDecodeInfo(fusion: 2.0, build: 284);
    const infoOld = ImageDecodeInfo(fusion: 1.5, build: 270);
    const infoPlus = ImageDecodeInfo(fusion: 2.5, build: 300, plus: true);

    final m3 = MmfImage()
      ..width = 2
      ..height = 1
      ..graphicMode = 3
      ..data = Uint8List.fromList([0, 1]);
    final pal = Uint8List.fromList([10, 20, 30, 0, 40, 50, 60, 0]);
    expect(decodeImage(m3, info, pal), [10, 20, 30, 255, 40, 50, 60, 255]);
    expect(() => decodeImage(m3, info), throwsUnsupportedError);

    final m3p = MmfImage()
      ..width = 2
      ..height = 2
      ..graphicMode = 3
      ..transparentColor = Uint8List.fromList([10, 20, 30, 0])
      ..data = Uint8List.fromList([0, 1, 9, 9, 1, 0, 9, 9]);
    expect(decodeImage(m3p, info, pal).length, 16);

    final m3r = MmfImage()
      ..width = 3
      ..height = 1
      ..graphicMode = 3
      ..flags = 1
      ..data = Uint8List.fromList([0x82, 1, 0x00, 0]);
    expect(decodeImage(m3r, info, pal).length, 12);

    final m4 = MmfImage()
      ..width = 2
      ..height = 1
      ..graphicMode = 4
      ..flags = 1
      ..data = Uint8List.fromList([0x80, 1, 2, 3]);
    expect(decodeImage(m4, info).length, 8);

    final m4a = MmfImage()
      ..width = 1
      ..height = 1
      ..graphicMode = 4
      ..flags = 0x10
      ..data = Uint8List.fromList([1, 2, 3, 0, 0, 0, 200, 0, 0, 0]);
    final o4a = decodeImage(m4a, info);
    expect(o4a[3], 200);

    final m6 = MmfImage()
      ..width = 1
      ..height = 1
      ..graphicMode = 6
      ..transparentColor = Uint8List.fromList([248, 248, 248, 0])
      ..data = Uint8List.fromList([0xFF, 0x7F]);
    final o6 = decodeImage(m6, info);
    expect(o6.sublist(0, 3), [248, 248, 248]);
    expect(o6[3], 0);

    final m7r = MmfImage()
      ..width = 2
      ..height = 1
      ..graphicMode = 7
      ..flags = 1
      ..data = Uint8List.fromList([0x80, 0xF8, 0x00]);
    expect(decodeImage(m7r, info).length, 8);

    final m7a = MmfImage()
      ..width = 1
      ..height = 1
      ..graphicMode = 7
      ..flags = 0x10
      ..data = Uint8List.fromList([0xFF, 0xFF, 0, 0, 0, 0]);
    final o7a = decodeImage(m7a, info);
    expect(o7a[3], 0);

    final m8 = MmfImage()
      ..width = 1
      ..height = 1
      ..graphicMode = 8
      ..flags = 0x80
      ..data = Uint8List.fromList([10, 20, 30, 99]);
    expect(decodeImage(m8, info), [30, 20, 10, 99]);

    final m8a = MmfImage()
      ..width = 1
      ..height = 1
      ..graphicMode = 8
      ..flags = 0x10
      ..data = Uint8List.fromList([10, 20, 30, 0]);
    expect(decodeImage(m8a, info)[3], 0);

    final m8t = MmfImage()
      ..width = 1
      ..height = 1
      ..graphicMode = 8
      ..transparentColor = Uint8List.fromList([10, 20, 30, 0])
      ..data = Uint8List.fromList([30, 20, 10, 0]);
    expect(decodeImage(m8t, info)[3], 0);

    final m8tail = MmfImage()
      ..width = 1
      ..height = 1
      ..graphicMode = 8
      ..flags = 0x10
      ..data = Uint8List.fromList([10, 20, 30, 0, 77, 0, 0, 0]);
    expect(decodeImage(m8tail, info)[3], 77);

    final pad = MmfImage()
      ..width = 1
      ..height = 1
      ..graphicMode = 4
      ..flags = 4
      ..data = Uint8List.fromList([1, 2, 3, 0, 0, 0]);
    decodeImage(pad, info);
    decodeImage(pad, infoOld);
    decodeImage(pad, infoPlus);
    decodeImage(pad, const ImageDecodeInfo(fusion: 2.0, build: 270));

    final bad = MmfImage()
      ..width = 1
      ..height = 1
      ..graphicMode = 5
      ..data = Uint8List(4);
    expect(() => decodeImage(bad, info), throwsUnsupportedError);
  });
}
