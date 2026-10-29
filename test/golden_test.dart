import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnaf_flutter/l10n/app_localizations.dart';
import 'package:fnaf_flutter/ui/sidebar.dart';
import 'package:fnaf_flutter/ui/screens.dart';
import 'package:fnaf_flutter/state/app_state.dart';
import 'package:provider/provider.dart';

Widget _wrap(Widget child, {AppState? app}) {
  return MaterialApp(
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(
      body: ChangeNotifierProvider<AppState>.value(
          value: app ?? AppState(), child: child)));
}

void main() {
  setUpAll(() async {
    final loader = FontLoader('Roboto')
      ..addFont(Future.value(
          ByteData.view(File('assets/Roboto-Regular.ttf').readAsBytesSync().buffer)));
    await loader.load();
  });

  testWidgets('sidebar golden', (t) async {
    await t.pumpWidget(_wrap(SizedBox(width: 400, height: 300,
        child: AppSidebar(items: [
          NavItem(Icons.play_arrow, 'New Game'),
          NavItem(Icons.settings, 'Settings'),
        ], selected: 0, onSelect: (_) {}))));
    await expectLater(find.byType(AppSidebar), matchesGoldenFile('sidebar.png'));
  });

  testWidgets('import screen golden', (t) async {
    await t.pumpWidget(_wrap(const ImportScreen()));
    await t.pumpAndSettle();
    await expectLater(find.byType(ImportScreen), matchesGoldenFile('import.png'));
  });

  testWidgets('lose screen golden', (t) async {
    await t.pumpWidget(_wrap(LoseScreen(onRetry: () {})));
    await expectLater(find.byType(LoseScreen), matchesGoldenFile('lose.png'));
  });
}
