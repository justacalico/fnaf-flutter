import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'l10n/app_localizations.dart';
import 'state/app_state.dart';
import 'ui/top_bar.dart';
import 'ui/sidebar.dart';
import 'ui/screens.dart';
import 'ui/game_screen.dart';

const appVersion = String.fromEnvironment('APP_VERSION', defaultValue: '0.0.1');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (isDesktop) {
    await windowManager.ensureInitialized();
    const opts = WindowOptions(
      size: Size(1280, 720),
      minimumSize: Size(800, 450),
      center: true,
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: false,
    );
    windowManager.waitUntilReadyToShow(opts, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  final app = AppState();
  await app.load();
  String version = appVersion;
  try {
    version = (await PackageInfo.fromPlatform()).version;
  } catch (_) {}
  runApp(FnafApp(app: app, version: version));
}

class FnafApp extends StatefulWidget {
  final AppState app;
  final String version;
  const FnafApp({super.key, required this.app, required this.version});
  @override
  State<FnafApp> createState() => _FnafAppState();
}

enum Page { play, settings }

class _FnafAppState extends State<FnafApp> {
  Page page = Page.play;
  int? playingNight;
  bool won = false;
  bool lost = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.app,
      child: Consumer<AppState>(builder: (context, app, _) {
        return MaterialApp(
          title: 'FNAF Flutter',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark(useMaterial3: true),
          locale: app.locale,
          supportedLocales: const [Locale('en'), Locale('zh'), Locale('ru'), Locale('ga')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: _shell(app),
        );
      }),
    );
  }

  Widget _shell(AppState app) {
    final l = AppLocalizations.of(context)!;
    Widget body;
    if (!app.hasAssets) {
      body = const ImportScreen();
    } else if (playingNight != null) {
      body = GameScreen(
        key: ValueKey('night$playingNight'),
        assets: app.assets!,
        night: playingNight!,
        fanMuted: app.fanMuted,
        onWin: () => setState(() { won = true; }),
        onLose: () => setState(() { lost = true; }),
      );
      if (won) {
        body = WinScreen(night: playingNight!, onNext: () {
          app.saveNight(playingNight! + 1);
          setState(() { won = false; playingNight = null; });
        });
      } else if (lost) {
        body = LoseScreen(onRetry: () => setState(() { lost = false; }));
      }
    } else if (page == Page.settings) {
      body = SettingsScreen(currentVersion: widget.version);
    } else {
      body = MenuScreen(
        onNewGame: () => setState(() { playingNight = 1; lost = false; won = false; }),
        onContinue: () => setState(() { playingNight = app.maxNight; lost = false; won = false; }),
        onSettings: () => setState(() => page = Page.settings),
      );
    }
    final nav = Scaffold(
      appBar: isDesktop ? MacTopBar(title: l.appTitle) : null,
      body: Row(children: [
        if (app.hasAssets && playingNight == null)
          AppSidebar(items: [
            NavItem(Icons.play_arrow, l.newGame),
            NavItem(Icons.settings, l.settings),
          ], selected: page == Page.settings ? 1 : 0, onSelect: (i) {
            setState(() {
              if (i == 0) page = Page.play;
              if (i == 1) page = Page.settings;
            });
          }),
        Expanded(child: body),
      ]),
    );
    return nav;
  }
}
