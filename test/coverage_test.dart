import 'dart:convert';
import 'dart:math';
import 'package:fnaf_flutter/utils/version_utils.dart';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fnaf_flutter/assets/asset_manifest.dart';
import 'package:fnaf_flutter/assets/asset_store.dart';
import 'package:fnaf_flutter/game/engine.dart';
import 'package:fnaf_flutter/l10n/app_localizations.dart';
import 'package:fnaf_flutter/services/audio_service.dart';
import 'package:fnaf_flutter/services/version_checker.dart';
import 'package:fnaf_flutter/state/app_state.dart';
import 'package:fnaf_flutter/ui/game_screen.dart';
import 'package:fnaf_flutter/ui/screens.dart';
import 'package:fnaf_flutter/ui/top_bar.dart';
import 'package:fnaf_flutter/main.dart';

import 'extractor_fixture_test.dart' show buildExe;

AssetStore fakeStore() {
  final png = Uint8List.fromList(img.encodePng(img.Image(width: 4, height: 4)));
  final images = <int, Uint8List>{};
  void add(int h) => images[h] = png;
  add(Assets.officeBase);
  add(Assets.doorLitEmpty);add(Assets.ceilingLights);
  add(Assets.doorLeftClose.last);add(Assets.doorRightClose.last);add(Assets.monitorFrame);
  add(Assets.bonnieAtDoor);
  add(Assets.chicaAtDoor);
  add(Assets.camMap);
  for (final id in Assets.titleBgs) { add(id); }
  
  for (final id in Assets.staticNoise) {
    add(id);
  }
  for (final v in Assets.camViews.values) {
    for (final id in v) {
      add(id);
    }
  }
  for (final v in [
    Assets.bonnieJumpscare,
    Assets.chicaJumpscare,
    Assets.freddyJumpscare,
    Assets.foxyJumpscare
  ]) {
    for (final id in v) {
      add(id);
    }
  }
  return AssetStore(images: images, sounds: const {}, appName: 'test');
}

Widget app(Widget child, {AppState? state, Locale? locale}) {
  return ChangeNotifierProvider<AppState>.value(
    value: state ?? AppState(),
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('engine edge cases', () {
    test('foxy runs and pounds door', () {
      final ev = _Events();
      final e = GameEngine(night: 1, rng: SystemRng(Random(1)), events: ev);
      e.leftDoorClosed = true;
      e.foxyStage = 4;
      final p0 = e.power;
      e.forceMove(Animatronic.foxy);
      expect(e.power, lessThan(p0));
      expect(e.foxyStage, 1);
      expect(ev.pounded, true);
      e.foxyStage = 4;
      e.foxyRunCooldown = 0;
      e.leftDoorClosed = false;
      e.forceMove(Animatronic.foxy);
      expect(e.dead, true);
      expect(e.jumpscareBy, Animatronic.foxy);
    });

    test('foxy slowed when watched', () {
      final e = GameEngine(night: 1, rng: _Even());
      e.monitorUp = true;
      e.currentCam = 'cam1c';
      e.foxyStage = 2;
      e.forceMove(Animatronic.foxy);
      expect(e.foxyStage, 2);
    });

    test('bonnie door bounce and entry', () {
      final e = GameEngine(night: 1, rng: SystemRng(Random(0)));
      e.pathIndex[Animatronic.bonnie] = bonniePath.length - 2;
      e.leftDoorClosed = true;
      e.forceMove(Animatronic.bonnie);
      expect(e.roomOf(Animatronic.bonnie), isNot(Room.leftDoor));
      e.pathIndex[Animatronic.bonnie] = bonniePath.length - 1;
      e.leftDoorClosed = false;
      e.forceMove(Animatronic.bonnie);
      expect(e.bonnieInOffice, true);
      e.bonnieAttackTimer = 0;
      e.tick(0.1);
      expect(e.jumpscareBy, Animatronic.bonnie);
    });

    test('bonnie in office forced out on close', () {
      final e = GameEngine(night: 1);
      e.bonnieInOffice = true;
      e.toggleLeftDoor();
      expect(e.bonnieInOffice, false);
      expect(e.leftDoorClosed, true);
      e.chicaInOffice = true;
      e.toggleRightDoor();
      expect(e.chicaInOffice, false);
    });

    test('chica entry and attack', () {
      final e = GameEngine(night: 1, rng: SystemRng(Random(0)));
      e.pathIndex[Animatronic.chica] = chicaPath.length - 1;
      e.forceMove(Animatronic.chica);
      expect(e.chicaInOffice, true);
      e.chicaAttackTimer = 0;
      e.tick(0.1);
      expect(e.dead, true);
    });

    test('chica door bounce', () {
      final e = GameEngine(night: 1, rng: SystemRng(Random(0)));
      e.pathIndex[Animatronic.chica] = chicaPath.length - 2;
      e.rightDoorClosed = true;
      e.forceMove(Animatronic.chica);
      expect(e.roomOf(Animatronic.chica), isNot(Room.rightDoor));
    });

    test('freddy moves when unwatched and enters', () {
      final e = GameEngine(night: 1, rng: SystemRng(Random(0)));
      e.monitorUp = true;
      e.currentCam = 'cam1a';
      e.forceMove(Animatronic.freddy);
      expect(e.roomOf(Animatronic.freddy), Room.showStage);
      e.currentCam = 'cam1b';
      e.forceMove(Animatronic.freddy);
      expect(e.roomOf(Animatronic.freddy), Room.diningArea);
      e.currentCam = 'cam2a';
      e.pathIndex[Animatronic.freddy] = freddyPath.length - 1;
      e.forceMove(Animatronic.freddy);
      expect(e.freddyInside, true);
      e.freddyAttackTimer = 0;
      e.tick(0.1);
      expect(e.dead, true);
    });

    test('freddy blocked by right door', () {
      final e = GameEngine(night: 1, rng: SystemRng(Random(0)));
      e.pathIndex[Animatronic.freddy] = freddyPath.length - 1;
      e.rightDoorClosed = true;
      e.forceMove(Animatronic.freddy);
      expect(e.freddyInside, false);
    });

    test('power out kills', () {
      final ev = _Events();
      final e = GameEngine(night: 1, rng: _Even(), events: ev);
      e.power = 0.01;
      e.tick(1);
      expect(e.powerOut, true);
      expect(ev.poweredOut, true);
      for (var i = 0; i < 60; i++) {
        e.tick(1);
      }
      expect(e.officeDarkOut, true);
      for (var i = 0; i < 200; i++) {
        e.tick(1);
      }
      expect(e.dead || e.won, true);
      e.toggleLeftDoor();
      e.toggleMonitor();
      e.selectCam('cam2a');
      expect(e.monitorUp, false);
    });

    test('light and occupants', () {
      final e = GameEngine(night: 1);
      e.pathIndex[Animatronic.bonnie] = bonniePath.length - 1;
      e.leftLight = true;
      expect(e.lightSeesLeft(), true);
      e.pathIndex[Animatronic.chica] = chicaPath.length - 1;
      e.rightLight = true;
      expect(e.lightSeesRight(), true);
      e.foxyStage = 2;
      expect(e.occupantsOf(Room.pirateCove), contains(Animatronic.foxy));
      expect(e.clockLabel, '12:00');
    });

    test('cam select without monitor does nothing', () {
      final e = GameEngine(night: 1);
      e.selectCam('cam5');
      expect(e.currentCam, 'cam1a');
    });

    test('foxy stage and cooldown', () {
      final e = GameEngine(night: 1, rng: _Odd());
      e.foxyRunCooldown = 5;
      e.foxyStage = 1;
      e.forceMove(Animatronic.foxy);
      expect(e.foxyStage, 1);
      e.foxyRunCooldown = 0;
      e.forceMove(Animatronic.foxy);
      expect(e.foxyStage, 2);
    });
  });

  group('version checker', () {
    test('finds newer release', () async {
      final c = VersionChecker(
          currentVersion: '0.1.0',
          client: http_testing.MockClient((req) async => http.Response(
              jsonEncode([
                {'tag_name': 'v0.2.0'},
                {'tag_name': 'v0.3.0'},
                {'tag_name': 'garbage'},
              ]),
              200)));
      final u = await c.check();
      expect(u?.version, const Version(0, 3, 0));
      expect(c.lastResult, true);
    });

    test('up to date on empty and error', () async {
      final c = VersionChecker(
          currentVersion: '9.9.9',
          client: http_testing.MockClient((req) async => http.Response('[]', 200)));
      expect(await c.check(), isNull);
      final c2 = VersionChecker(
          currentVersion: '9.9.9',
          client: http_testing.MockClient((req) async => http.Response('x', 500)));
      expect(await c2.check(), isNull);
      expect(c2.lastResult, false);
      final c3 = VersionChecker(
          currentVersion: '1.0.0',
          client: http_testing.MockClient((req) async => throw Exception('net')));
      expect(await c3.check(), isNull);
      expect(c3.lastResult, false);
      expect(VersionChecker.releasesUrl('v1.0.0').toString(), contains('v1.0.0'));
      expect(VersionChecker.releasesPage, contains('releases'));
    });
  });

  group('app state', () {
    test('load and persist', () async {
      SharedPreferences.setMockInitialValues({});
      final a = AppState();
      await a.load();
      expect(a.night, 1);
      await a.saveNight(3);
      expect(a.maxNight, 3);
      await a.saveNight(6);
      expect(a.stars, 1);
      await a.saveNight(7);
      expect(a.stars, 2);
      await a.setLocale(const Locale('ru'));
      expect(a.locale, const Locale('ru'));
      await a.setFanMuted(true);
      expect(a.fanMuted, true);
      await a.load();
      expect(a.locale, const Locale('ru'));
      await a.setLocale(null);
      expect(a.locale, isNull);
      a.forgetAssets();
      expect(a.hasAssets, false);
    });

    test('extract from bytes', () async {
      SharedPreferences.setMockInitialValues({});
      final a = AppState();
      await a.extractFrom(buildExe());
      expect(a.hasAssets, true);
      expect(a.assets!.appName, 'Test Game');
      await a.extractFrom(Uint8List(4));
      expect(a.extractError, 'extract_failed');
    });
  });

  group('audio service', () {
    test('plays nothing without data', () async {
      final s = AudioService({});
      s.enabled = false;
      await s.play('x');
      s.enabled = true;
      await s.play('missing');
      await s.stop('x');
      await s.stopAll();
      s.dispose();
    });
  });

  group('ui', () {
    testWidgets('import screen', (t) async {
      final a = AppState();
      await t.pumpWidget(app(const ImportScreen(), state: a));
      expect(find.text('Choose .exe'), findsOneWidget);
      a.extractError = 'x';
      await t.pump();
      a.extractError = null;
      await t.pump();
    });

    testWidgets('menu screen all locales', (t) async {
      for (final l in [null, const Locale('zh'), const Locale('ru'), const Locale('ga')]) {
        final a = AppState()
          ..assets = fakeStore()
          ..maxNight = 3
          ..stars = 2;
        await t.pumpWidget(app(
            MenuScreen(onNewGame: () {}, onContinue: () {}, onSettings: () {}),
            state: a, locale: l));
        expect(find.byType(MenuScreen), findsOneWidget);
      }
    });

    testWidgets('settings screen interactions', (t) async {
      SharedPreferences.setMockInitialValues({});
      final a = AppState();
      await a.load();
      a.assets = fakeStore();
      final checker = VersionChecker(
          currentVersion: '0.0.1',
          client: http_testing.MockClient(
              (r) async => http.Response(jsonEncode([{'tag_name': 'v9.9.9'}]), 200)));
      await t.pumpWidget(
          app(SettingsScreen(currentVersion: '0.0.1', checker: checker), state: a));
      await t.pumpAndSettle();
      await t.tap(find.byType(DropdownButton<Locale?>));
      await t.pumpAndSettle();
      await t.tap(find.text('Русский').last);
      await t.pumpAndSettle();
      await t.tap(find.byType(SwitchListTile));
      await t.pumpAndSettle();
      await t.tap(find.text('Remove extracted assets'));
      await t.pumpAndSettle();
      await t.tap(find.text('Reset save data'));
      await t.pumpAndSettle();
      await t.tap(find.text('Check for updates'));
      await t.pump();
      await t.pump(const Duration(seconds: 1));
      await t.pumpAndSettle();
      a.assets = fakeStore();
      await t.pump();
    });

    testWidgets('win and lose screens', (t) async {
      await t.pumpWidget(app(WinScreen(night: 6, onNext: () {})));
      expect(find.text('6:00 AM'), findsOneWidget);
      await t.tap(find.byType(OutlinedButton));
      await t.pumpWidget(app(LoseScreen(onRetry: () {})));
      expect(find.text('Game Over'), findsOneWidget);
      await t.tap(find.byType(OutlinedButton));
    });

    testWidgets('game screen basic + monitor', (t) async {
      final store = fakeStore();
      final e = GameEngine(night: 1, rng: SystemRng(Random(1)));
      await t.pumpWidget(app(GameScreen(
          assets: store, night: 1, onWin: () {}, onLose: () {}, engine: e,
          fanMuted: true)));
      await t.pump(const Duration(milliseconds: 100));
      await t.tap(find.byIcon(Icons.keyboard_arrow_up));
      await t.pump(const Duration(milliseconds: 100));
      expect(e.monitorUp, true);
      await t.tap(find.byKey(const Key('cambtn_cam1c')));
      await t.pump(const Duration(milliseconds: 100));
      await t.tap(find.byKey(const Key('cambtn_cam6')));
      await t.pump(const Duration(milliseconds: 100));
      await t.tap(find.byIcon(Icons.keyboard_arrow_down));
      await t.pump(const Duration(milliseconds: 100));
      await t.tap(find.text('DOOR').first);
      await t.pump(const Duration(milliseconds: 100));
      await t.tap(find.text('LIGHT').first);
      await t.pump(const Duration(milliseconds: 100));
      await t.tap(find.text('LIGHT').last);
      await t.pump(const Duration(milliseconds: 100));
      e.power = 0.01;
      await t.pump(const Duration(milliseconds: 200));
    });

    testWidgets('game screen jumpscare', (t) async {
      final store = fakeStore();
      final e = GameEngine(night: 1, rng: SystemRng(Random(1)));
      await t.pumpWidget(app(GameScreen(
          assets: store, night: 1, onWin: () {}, onLose: () {}, engine: e,
          fanMuted: true)));
      await t.pump(const Duration(milliseconds: 50));
      e.events.onJumpscare(Animatronic.bonnie);
      await t.pump(const Duration(milliseconds: 100));
      await t.pump(const Duration(seconds: 2));
    });

    testWidgets('top bar buttons', (t) async {
      var closed = 0;
      var mini = 0;
      var maxi = 0;
      WindowButtons.onClose = () async => closed++;
      WindowButtons.onMinimize = () async => mini++;
      WindowButtons.onMaximize = () async => maxi++;
      await t.pumpWidget(const MaterialApp(
          home: Scaffold(appBar: MacTopBar(title: 'x'))));
      expect(find.text('x'), findsOneWidget);
      for (final btn in find.byType(GestureDetector).evaluate().toList()) {
        final g = btn.widget as GestureDetector;
        g.onTap?.call();
      }
      expect(closed + mini + maxi, greaterThan(0));
      await WindowButtons.close();
      await WindowButtons.minimize();
      await WindowButtons.maximize();
      final top = find.byType(MacTopBar).evaluate().first.widget as MacTopBar;
      expect(top.preferredSize.height, 40);
    });

    testWidgets('full app shell', (t) async {
      SharedPreferences.setMockInitialValues({});
      final a = AppState();
      await a.load();
      await t.pumpWidget(FnafApp(app: a, version: '1.0.0'));
      await t.pumpAndSettle();
      expect(find.byType(ImportScreen), findsOneWidget);
      await t.runAsync(() => a.extractFrom(buildExe()));
      await t.pumpAndSettle();
      expect(find.byType(MenuScreen), findsOneWidget);
      await t.tap(find.widgetWithText(OutlinedButton, 'Settings'));
      await t.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
      await t.tap(find.byIcon(Icons.play_arrow).first);
      await t.pumpAndSettle();
      await a.saveNight(3);
      await t.pumpAndSettle();
      await t.tap(find.widgetWithText(OutlinedButton, 'Continue'));
      await t.pump(const Duration(milliseconds: 100));
    });
  });
}

class _Events extends EngineEvents {
  bool pounded = false;
  bool poweredOut = false;
  Animatronic? scared;
  @override
  void onJumpscare(Animatronic a) => scared = a;
  @override
  void onNightWin() {}
  @override
  void onPowerOut() => poweredOut = true;
  @override
  void onDoorPound() => pounded = true;
}

class _Even implements GameRng {
  @override
  int nextInt(int max) => 1;
  @override
  bool nextBool() => true;
  @override
  double nextDouble() => 0.1;
}

class _Odd implements GameRng {
  @override
  int nextInt(int max) => 0;
  @override
  bool nextBool() => false;
  @override
  double nextDouble() => 0.5;
}
