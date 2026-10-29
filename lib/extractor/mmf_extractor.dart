import 'dart:typed_data';

import 'byte_reader.dart';
import 'decompress.dart';
import 'image_decoder.dart';

class GameSound {
  final int handle;
  final String name;
  final int frequency;
  final Uint8List data;
  const GameSound(this.handle, this.name, this.frequency, this.data);
}

class PackEntry {
  final String name;
  final Uint8List data;
  const PackEntry(this.name, this.data);
}

class ExtractedGame {
  String appName = '';
  int build = 0;
  double fusion = 2.0;
  final Map<int, MmfImage> images = {};
  final List<GameSound> sounds = [];
  final List<PackEntry> packFiles = [];
  Uint8List? framePalette;

  Uint8List imageRgba(MmfImage img) {
    return decodeImage(
      img,
      ImageDecodeInfo(fusion: fusion, build: build),
      framePalette,
    );
  }
}

class MmfExtractException implements Exception {
  final String message;
  const MmfExtractException(this.message);
  @override
  String toString() => 'MmfExtractException: $message';
}

class MmfExtractor {
  static const _pame = 0x454D4150;
  static const _pamu = 0x554D4150;
  static const _packMagic = 0x77777777;

  static ExtractedGame extract(Uint8List exe) {
    if (exe.length < 64) {
      throw const MmfExtractException('file too small');
    }
    final game = ExtractedGame();
    final reader = ByteReader(exe);
    _seekGameData(reader);
    _readPackData(reader, game);
    _readPackage(reader, game);
    return game;
  }

  static void _seekGameData(ByteReader reader) {
    if (reader.readAscii(2) != 'MZ') {
      throw const MmfExtractException('not a Windows executable');
    }
    reader.seek(60);
    final hdrOffset = reader.readUShort();
    reader.seek(hdrOffset + 6);
    final numSections = reader.readUShort();
    reader.skip(240);
    var position = 0;
    var relocFallback = 0;
    for (var i = 0; i < numSections; i++) {
      final name = reader.readAsciiStop(8);
      reader.skip(8);
      final sectionStart = reader.readUInt();
      final sectionSize = reader.readUInt();
      reader.skip(16);
      if (position == 0) {
        position = sectionStart + sectionSize;
      } else {
        position += sectionStart;
      }
      if (name == '.reloc') relocFallback = sectionStart + sectionSize;
    }
    if (position > reader.end) {
      reader.seek(relocFallback != 0 ? relocFallback : reader.end);
    } else {
      reader.seek(position);
      if (!reader.hasMemory(1) &&
          relocFallback != position &&
          relocFallback != 0) {
        reader.seek(relocFallback);
      }
    }
  }

  static void _readPackData(ByteReader reader, ExtractedGame game) {
    if (!reader.hasMemory(4)) {
      throw const MmfExtractException('missing game data');
    }
    final magic = reader.peekInt();
    if (magic == _pame || magic == _pamu) return;
    if (magic == _packMagic) {
      reader.skip(28);
    } else {
      throw const MmfExtractException('unsupported executable data header');
    }
    final count = reader.readUInt();
    for (var i = 0; i < count; i++) {
      final len = reader.readShort();
      final name = reader.readYunicode(len);
      reader.readInt();
      final dataSize = reader.readInt();
      Uint8List data;
      if (reader.peekShort() == -9608) {
        data = decompressBlock(reader.readBytes(dataSize));
      } else {
        data = reader.readBytes(dataSize);
      }
      game.packFiles.add(PackEntry(name, data));
    }
  }

  static void _readPackage(ByteReader reader, ExtractedGame game) {
    final header = reader.readAscii(4);
    if (header != 'PAMU' && header != 'PAME') {
      throw MmfExtractException('bad game header: $header');
    }
    final unicode = header != 'PAME';
    final runtimeVersion = reader.readShort();
    reader.readShort();
    final productVersion = reader.readInt();
    game.build = reader.readInt();
    if (runtimeVersion != 769) {
      if (game.build < 280) {
        game.fusion = 2.0 + (productVersion == 1 ? 0.1 : 0);
      }
    } else {
      game.fusion = 1.5;
    }
    var optimizeImageSize = false;
    while (reader.hasMemory(8)) {
      final id = reader.readShort() & 0xFFFF;
      final flag = reader.readShort() & 0xFFFF;
      final size = reader.readInt();
      final raw = reader.readBytes(size);
      Uint8List data;
      switch (flag) {
        case 1:
          data = _decompressChunk(raw);
        case 2:
          data = raw;
        default:
          data = raw;
      }
      if (id == 0x7F7F) break;
      switch (id) {
        case 0x2224:
          game.appName = _readString(data, unicode);
        case 0x2245:
          if (data.length >= 12) {
            final cr = ByteReader(data);
            cr.skip(8);
            optimizeImageSize = (cr.readUInt() >> 9) & 1 == 1;
          }
        case 0x3333:
          _readFramePalette(data, game, unicode);
        case 0x6666:
          _readImageBank(data, game, optimizeImageSize);
        case 0x6668:
          _readSoundBank(data, game, unicode);
      }
    }
  }

  static Uint8List _decompressChunk(Uint8List raw) {
    final r = ByteReader(raw);
    r.readInt();
    final compSize = r.readInt();
    return decompressBlock(r.readBytes(compSize));
  }

  static String _readString(Uint8List data, bool unicode) {
    final r = ByteReader(data);
    return unicode ? r.readYunicode() : r.readAscii();
  }

  static void _readFramePalette(
      Uint8List frameData, ExtractedGame game, bool unicode) {
    if (game.framePalette != null) return;
    final r = ByteReader(frameData);
    while (r.hasMemory(8)) {
      final id = r.readShort() & 0xFFFF;
      final flag = r.readShort() & 0xFFFF;
      final size = r.readInt();
      final raw = r.readBytes(size);
      if (id == 0x3337) {
        final pr = ByteReader(flag == 1 ? _decompressChunk(raw) : raw);
        pr.readShort();
        final entries = pr.readShort();
        game.framePalette = pr.readBytes(entries * 4);
        return;
      }
      if (id == 0x7F7F) return;
    }
  }

  static void _readImageBank(
      Uint8List data, ExtractedGame game, bool optimizeImageSize) {
    final r = ByteReader(data);
    final count = r.readInt();
    for (var i = 0; i < count; i++) {
      final img = optimizeImageSize && game.fusion > 2.0
          ? _readImage25Plus(r)
          : _readImage25(r, game);
      game.images[img.handle] = img;
    }
  }

  static MmfImage _readImage25(ByteReader r, ExtractedGame game) {
    var handle = r.readUInt();
    if (game.build >= 284) handle--;
    r.readInt();
    final compSize = r.readInt();
    final decompressed = decompressBlock(r.readBytes(compSize));
    final dr = ByteReader(decompressed);
    final img = MmfImage();
    dr.readInt();
    dr.readInt();
    final dataSize = dr.readInt();
    img.handle = handle;
    img.width = dr.readShort();
    img.height = dr.readShort();
    img.graphicMode = dr.readByte();
    img.flags = dr.readByte();
    dr.readShort();
    img.hotspotX = dr.readShort();
    img.hotspotY = dr.readShort();
    img.actionPointX = dr.readShort();
    img.actionPointY = dr.readShort();
    img.transparentColor = dr.readBytes(4);
    if (img.flag(3)) {
      dr.readInt();
      img.data = decompressBlock(dr.readBytes(dr.remaining));
    } else {
      img.data = dr.readBytes(dataSize);
    }
    return img;
  }

  static MmfImage _readImage25Plus(ByteReader r) {
    final img = MmfImage();
    img.handle = r.readUInt() - 1;
    r.readInt();
    r.readInt();
    r.skip(4);
    final dataSize = r.readInt();
    img.width = r.readShort();
    img.height = r.readShort();
    img.graphicMode = r.readByte();
    img.flags = r.readByte();
    r.skip(2);
    img.hotspotX = r.readShort();
    img.hotspotY = r.readShort();
    img.actionPointX = r.readShort();
    img.actionPointY = r.readShort();
    img.transparentColor = r.readBytes(4);
    final decompSize = r.readInt();
    img.data = lz4Decompress(r.readBytes(dataSize - 4 > 0 ? dataSize - 4 : 0),
        decompSize);
    return img;
  }

  static void _readSoundBank(
      Uint8List data, ExtractedGame game, bool unicode) {
    final r = ByteReader(data);
    final count = r.readInt();
    for (var i = 0; i < count; i++) {
      var handle = r.readUInt();
      if (game.fusion >= 2.5) handle--;
      r.readInt();
      r.readUInt();
      final decompressedSize = r.readInt();
      final flags = r.readUInt();
      final frequency = r.readInt();
      final nameLength = r.readInt();
      final playFromDisk = (flags >> 5) & 1 == 1;
      ByteReader soundData;
      if (!playFromDisk) {
        final size = r.readInt();
        soundData = ByteReader(decompressBlock(r.readBytes(size)));
      } else {
        soundData = ByteReader(r.readBytes(decompressedSize));
      }
      final name = unicode
          ? soundData.readYuniversalStop(nameLength)
          : soundData.readAsciiStop(nameLength);
      if (playFromDisk) soundData.seek(0);
      game.sounds
          .add(GameSound(handle, name, frequency, soundData.readBytes()));
    }
  }
}
