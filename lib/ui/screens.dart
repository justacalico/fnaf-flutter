import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/links.dart';
import '../services/version_checker.dart';

import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import '../services/version_checker.dart';

class ImportScreen extends StatelessWidget {
  const ImportScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final app = context.watch<AppState>();
    return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.videogame_asset, size: 72, color: Colors.white54),
      const SizedBox(height: 16),
      Text(l.importExe, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
      const SizedBox(height: 8),
      Text(l.importHint, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 8),
      Text(l.importWarning, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 24),
      if (app.extracting) const Column(children: [CircularProgressIndicator(), SizedBox(height: 8), Text('...')]),
      if (!app.extracting)
        FilledButton.icon(onPressed: app.pickExe, icon: const Icon(Icons.folder_open), label: Text(l.chooseFile)),
      if (app.extractError != null) ...[
        const SizedBox(height: 12),
        Text(l.extractFailed, style: const TextStyle(color: Colors.red)),
      ],
    ])));
  }
}

class MenuScreen extends StatelessWidget {
  final VoidCallback onNewGame;
  final VoidCallback onContinue;
  final VoidCallback onSettings;
  const MenuScreen({super.key, required this.onNewGame, required this.onContinue, required this.onSettings});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final app = context.watch<AppState>();
    return Container(color: Colors.black, child: Stack(fit: StackFit.expand, children: [
      if (app.assets?.image(396) case final bg?)
        Image.memory(bg, fit: BoxFit.cover, opacity: const AlwaysStoppedAnimation(0.35)),
      Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Five Nights at Freddy\'s', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white, fontFamily: 'monospace')),
        const SizedBox(height: 40),
        for (final b in [
          (l.newGame, onNewGame),
          (l.continueGame, app.maxNight > 1 ? onContinue : null),
          (l.settings, onSettings),
        ])
          Padding(padding: const EdgeInsets.all(6), child: SizedBox(width: 260, child: OutlinedButton(
            onPressed: b.$2,
            style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54), padding: const EdgeInsets.all(16)),
            child: Text(b.$1, style: const TextStyle(fontSize: 18, fontFamily: 'monospace')),
          ))),
        const SizedBox(height: 24),
        Row(mainAxisSize: MainAxisSize.min, children: [
          for (var i = 0; i < app.stars; i++)
            const Icon(Icons.star, color: Colors.yellow, size: 28),
        ]),
        const SizedBox(height: 8),
        Text('©2014 Scott Cawthon — fan port', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white38)),
      ])),
    ]));
  }
}

class SettingsScreen extends StatelessWidget {
  final String currentVersion;
  final VersionChecker? checker;
  const SettingsScreen({super.key, required this.currentVersion, this.checker});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final app = context.watch<AppState>();
    return ListView(padding: const EdgeInsets.all(16), children: [
      ListTile(title: Text(l.language), trailing: DropdownButton<Locale?>(
        value: app.locale,
        items: [
          DropdownMenuItem(value: null, child: Text(l.systemLanguage)),
          const DropdownMenuItem(value: Locale('en'), child: Text('Traditional English')),
          const DropdownMenuItem(value: Locale('zh'), child: Text('简体中文')),
          const DropdownMenuItem(value: Locale('ru'), child: Text('Русский')),
          const DropdownMenuItem(value: Locale('ga'), child: Text('Gaeilge')),
        ],
        onChanged: app.setLocale,
      )),
      SwitchListTile(title: Text(l.fan), subtitle: Text(l.muteCall), value: app.fanMuted, onChanged: app.setFanMuted),
      ListTile(title: Text(l.removeAssets), onTap: app.forgetAssets),
      ListTile(title: Text(l.resetSave), onTap: () => app.saveNight(1)),
      const Divider(),
      _UpdateTile(currentVersion: currentVersion, checker: checker),
    ]);
  }
}

class _UpdateTile extends StatefulWidget {
  final String currentVersion;
  final VersionChecker? checker;
  const _UpdateTile({required this.currentVersion, this.checker});
  @override
  State<_UpdateTile> createState() => _UpdateTileState();
}

class _UpdateTileState extends State<_UpdateTile> {
  late final VersionChecker _own =
      VersionChecker(currentVersion: widget.currentVersion);
  VersionChecker get checker => widget.checker ?? _own;
  bool checking = false;
  bool? result;
  Future<void> _check() async {
    setState(() { checking = true; result = null; });
    final u = await checker.check();
    setState(() { checking = false; result = checker.lastResult; });
    if (u != null && mounted) {
      await Links.open(VersionChecker.releasesUrl(u.tag));
    }
  }
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ListTile(
        title: Text(l.checkUpdates),
        subtitle: Text('${l.version} ${widget.currentVersion}'),
        trailing: checking ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : null,
        onTap: checking ? null : _check,
      ),
      if (result == true && checker.lastUpdate == null)
        Padding(padding: const EdgeInsets.only(left: 16), child: Text(l.upToDate)),
      if (result == true && checker.lastUpdate != null)
        Padding(padding: const EdgeInsets.only(left: 16), child: InkWell(
          onTap: () => Links.open(VersionChecker.releasesUrl(checker.lastUpdate!.tag)),
          child: Text(l.updateAvailable(checker.lastUpdate!.version.toString()),
              style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
        )),
      if (result == false)
        Padding(padding: const EdgeInsets.only(left: 16), child: Text(l.updateFailed)),
      Padding(padding: const EdgeInsets.only(left: 16, top: 4), child: InkWell(
        onTap: () => Links.open(Uri.parse(VersionChecker.releasesPage)),
        child: Text(l.allReleases, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
      )),
    ]);
  }
}

class WinScreen extends StatelessWidget {
  final int night;
  final VoidCallback onNext;
  const WinScreen({super.key, required this.night, required this.onNext});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(color: Colors.black, child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('5:59 AM', style: TextStyle(color: Colors.white, fontSize: 48, fontFamily: 'monospace')),
      const SizedBox(height: 8),
      const Text('6:00 AM', style: TextStyle(color: Colors.yellow, fontSize: 48, fontFamily: 'monospace')),
      const SizedBox(height: 32),
      if (night >= 6) Text(l.theEnd, style: const TextStyle(color: Colors.white, fontSize: 32, fontFamily: 'monospace')),
      const SizedBox(height: 32),
      OutlinedButton(onPressed: onNext, child: Text(l.continueGame)),
    ])));
  }
}

class LoseScreen extends StatelessWidget {
  final VoidCallback onRetry;
  const LoseScreen({super.key, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(color: Colors.black, child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(l.gameOver, style: const TextStyle(color: Colors.red, fontSize: 40, fontFamily: 'monospace')),
      const SizedBox(height: 32),
      OutlinedButton(onPressed: onRetry, child: Text(l.continueGame)),
    ])));
  }
}
