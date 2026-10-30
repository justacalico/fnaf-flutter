import 'dart:typed_data';

import 'package:fnaf_flutter/extractor/mmf_extractor.dart';
import 'package:image/image.dart' as img;

class AssetStore {
  final Map<int, Uint8List> images;
  final Map<String, Uint8List> sounds;
  final String appName;

  const AssetStore({
    required this.images,
    required this.sounds,
    required this.appName,
  });

  Uint8List? image(int handle) => images[handle];
  Uint8List? sound(String name) => sounds[name];
}

class AssetExtractor {
  static AssetStore extract(Uint8List exeBytes,
      {void Function(double progress)? onProgress}) {
    final game = MmfExtractor.extract(exeBytes);
    final images = <int, Uint8List>{};
    var done = 0;
    final total = game.images.length + game.sounds.length;
    for (final e in game.images.entries) {
      final rgba = game.imageRgba(e.value);
      images[e.key] = Uint8List.fromList(img.encodePng(
          img.Image.fromBytes(
              width: e.value.width,
              height: e.value.height,
              bytes: rgba.buffer,
              numChannels: 4),
          level: 4));
      onProgress?.call(++done / total);
    }
    final sounds = <String, Uint8List>{};
    for (final s in game.sounds) {
      sounds[s.name] = s.data;
      onProgress?.call(++done / total);
    }
    return AssetStore(images: images, sounds: sounds, appName: game.appName);
  }
}

class AssetStoreCodec {
  static Uint8List encode(AssetStore s) {
    final out = BytesBuilder();
    void w32(int v) => out.add((ByteData(4)..setUint32(0, v)).buffer.asUint8List());
    void w16(int v) => out.add((ByteData(2)..setUint16(0, v)).buffer.asUint8List());
    out.add(const [70, 78, 65, 49]);
    final name = s.appName.codeUnits;
    w16(name.length);
    out.add(name);
    w32(s.images.length);
    s.images.forEach((h, d) {
      w32(h);
      w32(d.length);
      out.add(d);
    });
    w32(s.sounds.length);
    s.sounds.forEach((n, d) {
      final nb = n.codeUnits;
      w16(nb.length);
      out.add(nb);
      w32(d.length);
      out.add(d);
    });
    return out.toBytes();
  }

  static AssetStore decode(Uint8List data) {
    var p = 4;
    int r32() {
      final v = ByteData.sublistView(data, p).getUint32(0);
      p += 4;
      return v;
    }

    int r16() {
      final v = ByteData.sublistView(data, p).getUint16(0);
      p += 2;
      return v;
    }

    final nameLen = r16();
    final appName = String.fromCharCodes(data.sublist(p, p + nameLen));
    p += nameLen;
    final images = <int, Uint8List>{};
    for (var i = r32(); i > 0; i--) {
      images[r32()] = data.sublist(p + 4, p + 4 + ByteData.sublistView(data, p).getUint32(0));
      p += 4 + images.values.last.length;
    }
    final sounds = <String, Uint8List>{};
    for (var i = r32(); i > 0; i--) {
      final nl = r16();
      final n = String.fromCharCodes(data.sublist(p, p + nl));
      p += nl;
      sounds[n] = data.sublist(p + 4, p + 4 + ByteData.sublistView(data, p).getUint32(0));
      p += 4 + sounds.values.last.length;
    }
    return AssetStore(images: images, sounds: sounds, appName: appName);
  }
}
