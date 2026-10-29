import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const LandingApp());

class LandingApp extends StatefulWidget {
  const LandingApp({super.key});
  @override
  State<LandingApp> createState() => _LandingAppState();
}

enum LandingTheme { system, light, dark, oled }

class _LandingAppState extends State<LandingApp> {
  LandingTheme theme = LandingTheme.system;
  List<dynamic> releases = [];
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await http.get(Uri.parse(
          'https://gitlab.com/api/v4/projects/HttpAnimations%2Ffnaf-flutter/releases?per_page=20'));
      if (r.statusCode == 200) {
        setState(() { releases = jsonDecode(r.body) as List; loaded = true; });
        return;
      }
    } catch (_) {}
    setState(() => loaded = true);
  }

  ThemeData _theme() => switch (theme) {
        LandingTheme.light => ThemeData.light(useMaterial3: true),
        LandingTheme.dark || LandingTheme.system => ThemeData.dark(useMaterial3: true),
        LandingTheme.oled => ThemeData.dark(useMaterial3: true).copyWith(
            scaffoldBackgroundColor: Colors.black,
            cardColor: Colors.black,
          ),
      };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FNAF Flutter',
      theme: _theme(),
      home: Scaffold(
        appBar: AppBar(title: const Text('FNAF Flutter'), actions: [
          for (final t in LandingTheme.values)
            TextButton(
              onPressed: () => setState(() => theme = t),
              child: Text(t.name.toUpperCase(),
                  style: TextStyle(
                      color: theme == t ? Colors.redAccent : Colors.grey)),
            ),
        ]),
        body: ListView(padding: const EdgeInsets.all(24), children: [
          Text('A faithful port of the original survival horror classic.',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Wrap(spacing: 12, children: [
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.play_arrow),
              label: const Text('Play in browser'),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.code),
              label: const Text('View on GitLab'),
            ),
          ]),
          const SizedBox(height: 32),
          Text('Download', style: Theme.of(context).textTheme.titleLarge),
          if (!loaded) const CircularProgressIndicator(),
          if (loaded && releases.isEmpty)
            const Text('No releases yet — check back after the first build.'),
          for (final r in releases)
            Card(child: ListTile(
              title: Text(r['name'] ?? r['tag_name'] ?? ''),
              subtitle: Text((r['released_at'] ?? '').toString().split('T').first),
              trailing: TextButton(
                onPressed: () {},
                child: const Text('Download'),
              ),
            )),
        ]),
      ),
    );
  }
}
