import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import 'asset_store.dart';

// coverage:ignore-start
class AssetCache {
  static Future<File> _file() async =>
      File('${(await getApplicationSupportDirectory()).path}/assets.bin');

  static Future<AssetStore?> load() async {
    try {
      final f = await _file();
      if (!await f.exists()) return null;
      final data = await f.readAsBytes();
      if (data.length < 4 ||
          data[0] != 70 || data[1] != 78 || data[2] != 65 || data[3] != 49) {
        return null;
      }
      return AssetStoreCodec.decode(Uint8List.fromList(data));
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(AssetStore s) async {
    try {
      await (await _file()).writeAsBytes(AssetStoreCodec.encode(s), flush: true);
    } catch (_) {}
  }

  static Future<void> clear() async {
    try {
      final f = await _file();
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }
}
// coverage:ignore-end
