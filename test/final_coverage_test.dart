import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:fnaf_flutter/extractor/image_decoder.dart';
import 'package:fnaf_flutter/extractor/mmf_extractor.dart';
import 'package:fnaf_flutter/game/engine.dart';
import 'package:fnaf_flutter/l10n/app_localizations.dart';
import 'package:fnaf_flutter/l10n/app_localizations_en.dart';
import 'package:fnaf_flutter/services/links.dart';
import 'package:fnaf_flutter/services/version_checker.dart';
import 'package:fnaf_flutter/state/app_state.dart';
import 'package:fnaf_flutter/ui/game_screen.dart';
import 'package:fnaf_flutter/ui/screens.dart';
import 'package:fnaf_flutter/ui/top_bar.dart';
import 'package:fnaf_flutter/utils/version_utils.dart';
import 'package:fnaf_flutter/main.dart';

import 'coverage_test.dart' show fakeStore, app;
import 'extractor_fixture_test.dart' show buildExe;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('l10n en_GB getters and lookup', () {
    AppLocalizations l = AppLocalizationsEnGb();
    l.appTitle; l.importExe; l.importHint; l.chooseFile; l.extracting;
    l.extractFailed; l.newGame; l.continueGame; l.night; l.customNight;
    l.settings; l.about; l.language; l.systemLanguage; l.checkUpdates;
    l.checking; l.upToDate; l.updateFailed; l.version; l.muteCall;
    l.fan; l.powerLeft; l.usage; l.timeAm; l.warning; l.gameOver;
    l.goodJob; l.theEnd; l.door; l.light; l.importWarning; l.resetSave;
    l.removeAssets; l.download; l.getTheGame; l.landingTagline;
    l.features; l.theme; l.systemTheme; l.lightTheme; l.darkTheme;
    l.oledTheme; l.playInBrowser; l.viewOnGitLab;
    l.night(1); l.nightN(1); l.updateAvailable('1');
    l.viewRelease; l.allReleases;
    expect(lookupAppLocalizations(const Locale('en', 'GB')),
        isA<AppLocalizationsEnGb>());
    expect(lookupAppLocalizations(const Locale('en')),
        isA<AppLocalizationsEn>());
    expect(() => lookupAppLocalizations(const Locale('fr')),
        throwsFlutterError);
  });

  test('extractor exception toString + flag2 + header checks', () {
    const e = MmfExtractException('x');
    expect(e.toString(), 'MmfExtractException: x');
    final g = MmfExtractor.extract(buildExe(flag2Name: true));
    expect(g.appName, 'Test Game');
    final g2 = MmfExtractor.extract(buildExe(runtimeVersion: 769, unicode: true));
    expect(g2.fusion, 1.5);
    final g3 = MmfExtractor.extract(buildExe(nameFlag: 1));
    expect(g3.appName, 'Test Game');
    expect(MmfExtractor.extract(buildExe(noPalette: true)).framePalette, isNull);
    expect(() => MmfExtractor.extract(buildExe(header: 'XXXX')),
        throwsA(isA<MmfExtractException>()));
  });

  test('decoder rle advance + transparent + init zero', () {
    const info = ImageDecodeInfo(fusion: 2.0, build: 284);
    final m = MmfImage()
      ..width = 2
      ..height = 1
      ..graphicMode = 4
      ..flags = 1
      ..data = Uint8List.fromList([0x01, 5, 6, 7, 0x82, 8, 9, 10]);
    expect(decodeImage(m, info).length, 8);
    final m0 = MmfImage()
      ..width = 1
      ..height = 1
      ..graphicMode = 4
      ..flags = 1
      ..data = Uint8List.fromList([0x00, 5, 6, 7]);
    expect(decodeImage(m0, info).length, 4);
    final mt = MmfImage()
      ..width = 1
      ..height = 1
      ..graphicMode = 4
      ..transparentColor = Uint8List.fromList([255, 0, 0, 0])
      ..data = Uint8List.fromList([0, 0, 255]);
    expect(decodeImage(mt, info)[3], 0);
  });

  test('engine win + rng passthrough', () {
    final e = GameEngine(night: 1);
    e.timeSeconds = NightConfig.hourSeconds * 6;
    e.tick(0.1);
    expect(e.won, true);
    final e2 = GameEngine(night: 1, rng: _AllHigh());
    for (var i = 0; i < 30; i++) {
      e2.tick(5.1);
    }
    final e3 = GameEngine(night: 1);
    e3.monitorUp = true;
    e3.currentCam = 'cam1c';
    e3.forceMove(Animatronic.foxy);
    e3.monitorUp = false;
    e3.pathIndex[Animatronic.bonnie] = bonniePath.length - 1;
    e3.leftDoorClosed = false;
    e3.bonnieInOffice = false;
    e3.forceMove(Animatronic.bonnie);
    expect(e3.bonnieInOffice, true);
  });

  test('version pagination', () async {
    var page = 0;
    final c = VersionChecker(
        currentVersion: '0.0.1',
        client: http_testing.MockClient((req) async {
          page++;
          if (page == 1) {
            return http.Response(
                jsonEncode(List.generate(
                    100, (i) => {'tag_name': 'v0.0.$i'})),
                200);
          }
          return http.Response(jsonEncode([{'tag_name': 'v0.9.0'}]), 200);
        }));
    final u = await c.check();
    expect(u?.version, const Version(0, 9, 0));
    expect(page, 2);
  });

  test('version equality', () {
    expect(const Version(1, 0, 0) == 'x', false);
    expect(const Version(1, 0, 0).hashCode, isA<int>());
  });

  test('version checker default client fails', () async {
    final c = VersionChecker(currentVersion: '1.0.0');
    await c.check();
    expect(c.lastResult, false);
  });

  test('app state loads saved locale', () async {
    SharedPreferences.setMockInitialValues({'save_locale': 'ga'});
    final a = AppState();
    await a.load();
    expect(a.locale, const Locale('ga'));
  });

  testWidgets('import extracting state', (t) async {
    final a = AppState()..extracting = true;
    await t.pumpWidget(app(const ImportScreen(), state: a));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('import error shown', (t) async {
    final a = AppState();
    await t.runAsync(() => a.extractFrom(Uint8List(4)));
    await t.pumpWidget(app(const ImportScreen(), state: a));
    expect(find.textContaining('Extraction failed'), findsOneWidget);
  });

  testWidgets('update tile failed state', (t) async {
    final a = AppState()..assets = fakeStore();
    final c = VersionChecker(
        currentVersion: '0.0.1',
        client: http_testing.MockClient((r) async => http.Response('x', 500)));
    await t.pumpWidget(
        app(SettingsScreen(currentVersion: '0.0.1', checker: c), state: a));
    await t.tap(find.text('Check for updates'));
    await t.pumpAndSettle();
    expect(find.text('Update check failed.'), findsOneWidget);
  });

  testWidgets('update tile all states', (t) async {
    Links.open = (uri) async => true;
    final a = AppState()..assets = fakeStore();
    final c = VersionChecker(
        currentVersion: '0.0.1',
        client: http_testing.MockClient((r) async =>
            http.Response(jsonEncode([{'tag_name': 'v9.9.9'}]), 200)));
    await t.pumpWidget(
        app(SettingsScreen(currentVersion: '0.0.1', checker: c), state: a));
    await t.tap(find.text('Check for updates'));
    await t.pumpAndSettle();
    expect(find.textContaining('9.9.9'), findsOneWidget);
    await t.tap(find.textContaining('9.9.9'));
    await t.tap(find.text('All releases'));
    await t.pumpAndSettle();
    final c2 = VersionChecker(
        currentVersion: '9.9.9',
        client: http_testing.MockClient((r) async => http.Response('[]', 200)));
    await t.pumpWidget(
        app(SettingsScreen(currentVersion: '9.9.9', checker: c2), state: a));
    await t.tap(find.text('Check for updates'));
    await t.pumpAndSettle();
    expect(find.text('You are up to date.'), findsOneWidget);
  });

  testWidgets('top bar hover', (t) async {
    WindowButtons.onClose = () async {};
    WindowButtons.onMinimize = () async {};
    WindowButtons.onMaximize = () async {};
    await t.pumpWidget(const MaterialApp(
        home: Scaffold(appBar: MacTopBar(title: 'x'))));
    final g = await t.createGesture(kind: PointerDeviceKind.mouse);
    await g.moveTo(t.getCenter(find.byWidgetPredicate((w) =>
        w is Container &&
        w.decoration is BoxDecoration &&
        (w.decoration as BoxDecoration).shape == BoxShape.circle).first));
    await t.pump();
    await g.moveTo(const Offset(600, 300));
    await t.pump();
  });

  testWidgets('game screen doors lights scare variants', (t) async {
    final store = fakeStore();
    final e = GameEngine(night: 1, rng: _AllHigh());
    await t.pumpWidget(app(GameScreen(
        assets: store, night: 1, onWin: () {}, onLose: () {}, engine: e,
        fanMuted: true)));
    e.leftDoorClosed = true;
    e.rightDoorClosed = true;
    e.leftLight = true;
    e.rightLight = true;
    e.pathIndex[Animatronic.bonnie] = bonniePath.length - 1;
    e.pathIndex[Animatronic.chica] = chicaPath.length - 1;
    await t.pump(const Duration(milliseconds: 100));
    final g = await t.createGesture(kind: PointerDeviceKind.mouse);
    await g.moveTo(const Offset(400, 300));
    await t.pump();
    for (final a in Animatronic.values) {
      await t.pumpWidget(app(GameScreen(
          assets: store, night: 1, onWin: () {}, onLose: () {}, engine: e,
          fanMuted: true)));
      e.jumpscareBy = a;
      e.events.onJumpscare(a);
      await t.pump(const Duration(milliseconds: 30));
    }
  });

  testWidgets('game screen events', (t) async {
    var won = 0;
    final store = fakeStore();
    final e = GameEngine(night: 1, rng: _AllHigh());
    await t.pumpWidget(app(GameScreen(
        assets: store, night: 1, onWin: () => won++, onLose: () {}, engine: e,
        fanMuted: true)));
    await t.pump(const Duration(milliseconds: 50));
    e.events.onDoorPound();
    e.events.onPowerOut();
    e.events.onNightWin();
    await t.pump(const Duration(milliseconds: 100));
    expect(won, 1);
  });

  testWidgets('app shell game and end states', (t) async {
    SharedPreferences.setMockInitialValues({});
    final a = AppState();
    await a.load();
    await t.pumpWidget(FnafApp(app: a, version: '1.0.0'));
    await t.runAsync(() => a.extractFrom(buildExe()));
    await t.pumpAndSettle();
    await t.tap(find.widgetWithText(OutlinedButton, 'New Game'));
    await t.pump(const Duration(milliseconds: 100));
    expect(find.byType(GameScreen), findsOneWidget);
    final st = t.state(find.byType(FnafApp));
    (st as dynamic).startNight(1);
    await t.pump(const Duration(milliseconds: 100));
    (st as dynamic).debugWin();
    await t.pumpAndSettle();
    expect(find.byType(WinScreen), findsOneWidget);
    await t.tap(find.byType(OutlinedButton));
    await t.pumpAndSettle();
    (st as dynamic).startNight(1);
    await t.pump(const Duration(milliseconds: 100));
    (st as dynamic).debugLose();
    await t.pumpAndSettle();
    expect(find.byType(LoseScreen), findsOneWidget);
  });
}

class _AllHigh implements GameRng {
  @override
  int nextInt(int max) => 0;
  @override
  bool nextBool() => false;
  @override
  double nextDouble() => 0.99;
}
