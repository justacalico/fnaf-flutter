import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final Map<String, AudioPlayer> _players = {};
  final Map<String, Uint8List> _sounds;
  bool enabled = true;

  AudioService(this._sounds);

  Future<void> play(String name, {bool loop = false, double volume = 1.0}) async {
    if (!enabled) return;
    final data = _sounds[name];
    if (data == null) return;
    // coverage:ignore-start
    final p = _players.putIfAbsent(name, () => AudioPlayer());
    if (loop) await p.setReleaseMode(ReleaseMode.loop);
    await p.setVolume(volume);
    await p.play(BytesSource(data));
    // coverage:ignore-end
  }

  Future<void> stop(String name) async {
    // coverage:ignore-start
    await _players[name]?.stop();
    // coverage:ignore-end
  }

  Future<void> stopAll() async {
    // coverage:ignore-start
    for (final p in _players.values) {
      await p.stop();
    }
    // coverage:ignore-end
  }

  void dispose() {
    // coverage:ignore-start
    for (final p in _players.values) {
      p.dispose();
    }
    // coverage:ignore-end
  }
}
