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
