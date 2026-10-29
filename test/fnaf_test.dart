import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fnaf_flutter/extractor/byte_reader.dart';
import 'package:fnaf_flutter/extractor/decompress.dart';
import 'package:fnaf_flutter/extractor/image_decoder.dart';
import 'package:fnaf_flutter/extractor/mmf_extractor.dart';
import 'package:fnaf_flutter/game/engine.dart';
import 'package:fnaf_flutter/utils/version_utils.dart';
import 'package:fnaf_flutter/assets/asset_store.dart';
import 'package:archive/archive.dart';

Uint8List zlib(Uint8List d) =>
    Uint8List.fromList(const ZLibEncoder().encode(d));

void main() {
  test('byte reader primitives', () {
    final r = ByteReader(Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8, 0, 0, 65, 0, 0]));
    expect(r.readByte(), 1);
    expect(r.readShort(), 0x0302);
    expect(r.readUShort(), 0x0504);
    expect(r.readInt(), 0x080706);
    expect(r.peekInt(), 0x4100);
    expect(r.readAscii(1), '');
    expect(r.readAscii(1), 'A');
    expect(() => r.seek(99), throwsRangeError);
    expect(r.hasMemory(99), false);
  });

  test('decompress zlib and raw deflate', () {
    final src = Uint8List.fromList(List.generate(100, (i) => i % 7));
    final z = decompressBlock(zlib(src));
    expect(z, src);
    expect(isZlib(zlib(src)), true);
    expect(isZlib(Uint8List.fromList([0x78, 0x00])), false);
    final lz = lz4Decompress(Uint8List.fromList([0x30, 1, 2, 3]), 3);
    expect(lz, [1, 2, 3]);
  });

  test('image decoder mode 4', () {
    final img = MmfImage()
      ..width = 2
      ..height = 2
      ..graphicMode = 4
      ..flags = 0
      ..transparentColor = Uint8List.fromList([255, 0, 0, 0])
      ..data = Uint8List.fromList([
        10, 20, 30, 255, 0, 0,
        40, 50, 60, 70, 80, 90,
        0, 0,
      ]);
    const info = ImageDecodeInfo(fusion: 2.0, build: 284);
    final out = decodeImage(img, info);
    expect(out.length, 16);
    expect(out.sublist(0, 4), [30, 20, 10, 255]);
    expect(out.sublist(4, 8), [0, 0, 255, 255]);
    expect(out.sublist(8, 12), [60, 50, 40, 255]);
  });

  test('image decoder mode 7', () {
    final img = MmfImage()
      ..width = 1
      ..height = 1
      ..graphicMode = 7
      ..transparentColor = Uint8List.fromList([248, 252, 248, 0])
      ..data = Uint8List.fromList([0xFF, 0xFF]);
    const info = ImageDecodeInfo(fusion: 2.0, build: 284);
    final out = decodeImage(img, info);
    expect(out.sublist(0, 3), [248, 252, 248]);
    expect(out[3], 0);
  });

  test('extractor rejects non-exe', () {
    expect(() => MmfExtractor.extract(Uint8List.fromList([0])),
        throwsA(isA<MmfExtractException>()));
  });

  test('version parse and compare', () {
    expect(Version.parse('v1.2.3'), const Version(1, 2, 3));
    expect(Version.parse('1.2.3-beta'), const Version(1, 2, 3));
    expect(Version.parse('bad'), isNull);
    expect(const Version(1, 0, 1) > const Version(1, 0, 0), true);
    expect(const Version(2, 0, 0).compareTo(const Version(1, 9, 9)) > 0, true);
    expect(const Version(1, 0, 0) == const Version(1, 0, 0), true);
    expect(const Version(1, 0, 0).toString(), '1.0.0');
  });

  test('engine mechanics', () {
    final e = GameEngine(night: 1, rng: SystemRng(Random(0)));
    expect(e.power, 100);
    expect(e.hour, 0);
    expect(e.clockLabel, '12:00');
    e.toggleLeftDoor();
    expect(e.leftDoorClosed, true);
    expect(e.usageLevel, 2);
    e.toggleRightDoor();
    expect(e.usageLevel, 3);
    e.toggleMonitor();
    expect(e.monitorUp, true);
    expect(e.usageLevel, 4);
    e.selectCam('cam2a');
    expect(e.currentCam, 'cam2a');
    for (var i = 0; i < 6000; i++) e.tick(0.1);
    expect(e.won || e.dead || e.powerOut, true);
  });

  test('engine power out', () {
    final e = GameEngine(night: 1, rng: SystemRng(Random(0)));
    e.power = 0.01;
    e.tick(1);
    expect(e.powerOut, true);
    expect(e.leftDoorClosed, false);
  });

  test('engine door blocks', () {
    final e = GameEngine(night: 1, rng: SystemRng(Random(0)));
    e.pathIndex[Animatronic.bonnie] = 6;
    e.leftDoorClosed = true;
    e.tick(0.1);
    for (var i = 0; i < 100; i++) e.tick(0.1);
    expect(e.dead, false);
  });

  test('cam rooms and occupants', () {
    final e = GameEngine(night: 1);
    expect(camRooms['cam1a'], Room.showStage);
    expect(e.occupantsOf(Room.showStage), containsAll([Animatronic.bonnie, Animatronic.chica, Animatronic.freddy]));
    expect(e.roomOf(Animatronic.foxy), Room.pirateCove);
  });

  test('asset store lookup', () {
    final s = AssetStore(images: {1: Uint8List(1)}, sounds: const {}, appName: 'x');
    expect(s.appName, 'x');
  });
}

