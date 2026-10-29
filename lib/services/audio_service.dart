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
    final p = _players.putIfAbsent(name, () => AudioPlayer());
    if (loop) await p.setReleaseMode(ReleaseMode.loop);
    await p.setVolume(volume);
    await p.play(BytesSource(data));
  }

  Future<void> stop(String name) async {
    await _players[name]?.stop();
  }

  Future<void> stopAll() async {
    for (final p in _players.values) {
      await p.stop();
    }
  }

  void dispose() {
    for (final p in _players.values) {
      p.dispose();
    }
  }
}
