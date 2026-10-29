import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../assets/asset_store.dart';

AssetStore _extractWorker(Uint8List bytes) =>
    AssetExtractor.extract(bytes);

class AppState extends ChangeNotifier {
  AssetStore? assets;
  bool extracting = false;
  double extractProgress = 0;
  String? extractError;
  int night = 1;
  int maxNight = 1;
  int stars = 0;
  bool fanMuted = false;
  Locale? locale;

  static const _kNight = 'save_night';
  static const _kStars = 'save_stars';
  static const _kLocale = 'save_locale';
  static const _kFanMuted = 'fan_muted';

  bool get hasAssets => assets != null;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    night = p.getInt(_kNight) ?? 1;
    maxNight = p.getInt(_kNight) ?? 1;
    stars = p.getInt(_kStars) ?? 0;
    fanMuted = p.getBool(_kFanMuted) ?? false;
    final l = p.getString(_kLocale);
    if (l != null && l.isNotEmpty) locale = Locale(l);
    notifyListeners();
  }

  Future<void> pickExe() async {
    final files = await FilePicker.pickFiles(type: FileType.custom);
    if (files.isEmpty) return;
    if (files.single.extension != 'exe') {
      extractError = 'read_failed';
      notifyListeners();
      return;
    }
    await extractFrom(await files.single.readAsBytes());
  }

  Future<void> extractFrom(Uint8List bytes) async {
    extracting = true;
    extractError = null;
    extractProgress = 0;
    notifyListeners();
    try {
      assets = await compute(_extractWorker, bytes);
    } catch (_) {
      extractError = 'extract_failed';
    }
    extracting = false;
    notifyListeners();
  }

  Future<void> saveNight(int n) async {
    night = n;
    if (n > maxNight) maxNight = n;
    if (n >= 6) stars = stars < 1 ? 1 : stars;
    if (n >= 7) stars = 2;
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kNight, maxNight);
    await p.setInt(_kStars, stars);
    notifyListeners();
  }

  Future<void> setLocale(Locale? l) async {
    locale = l;
    final p = await SharedPreferences.getInstance();
    if (l == null) {
      await p.remove(_kLocale);
    } else {
      await p.setString(_kLocale, l.languageCode);
    }
    notifyListeners();
  }

  Future<void> setFanMuted(bool v) async {
    fanMuted = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kFanMuted, v);
    notifyListeners();
  }

  void forgetAssets() {
    assets = null;
    notifyListeners();
  }
}
