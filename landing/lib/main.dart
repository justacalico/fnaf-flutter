import 'dart:convert';
import 'package:web/web.dart' as web;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const Landing());

class Landing extends StatefulWidget {
  const Landing({super.key});
  @override
  State<Landing> createState() => _LandingState();
}

enum LandingTheme { system, light, dark, oled }

class _LandingState extends State<Landing> {
  LandingTheme theme = LandingTheme.system;
  List<dynamic> releases = [];
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    http.get(Uri.parse(
            'https://gitlab.com/api/v4/projects/HttpAnimations%2Ffnaf-flutter/releases?per_page=20'))
        .then((r) {
      if (r.statusCode == 200) {
        setState(() { releases = jsonDecode(r.body) as List; loaded = true; });
      } else {
        setState(() { loaded = true; });
      }
    }).catchError((_) => setState(() { loaded = true; }));
  }

  void _go(String url) => web.window.open(url, '_blank');

  ThemeData _theme() => switch (theme) {
        LandingTheme.light => ThemeData.light(useMaterial3: true),
        LandingTheme.dark || LandingTheme.system => ThemeData.dark(useMaterial3: true),
        LandingTheme.oled => ThemeData.dark(useMaterial3: true).copyWith(
            scaffoldBackgroundColor: Colors.black,
            cardColor: const Color(0xFF0A0A0A),
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
            IconButton(
              onPressed: () => setState(() => theme = t),
              icon: Icon(switch (t) {
                LandingTheme.system => Icons.brightness_auto,
                LandingTheme.light => Icons.light_mode,
                LandingTheme.dark => Icons.dark_mode,
                LandingTheme.oled => Icons.invert_colors,
              }, color: theme == t ? Colors.redAccent : Colors.grey)),
        ]),
        body: ListView(padding: const EdgeInsets.all(24), children: [
          Text('A faithful port of the original survival horror classic.',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Wrap(spacing: 12, children: [
            FilledButton.icon(
              onPressed: () => _go('/app/'),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Play in browser'),
            ),
            OutlinedButton.icon(
              onPressed: () => _go('https://gitlab.com/HttpAnimations/fnaf-flutter'),
              icon: const Icon(Icons.code),
              label: const Text('View on GitLab'),
            ),
          ]),
          const SizedBox(height: 32),
          Text('Showcase', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          LayoutBuilder(builder: (context, c) => Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _Showcase(title: 'Office', child: SizedBox(
                  width: 220, height: 140,
                  child: CustomPaint(painter: _OfficePainter()))),
              _Showcase(title: 'Monitor', child: SizedBox(
                  width: 220, height: 140,
                  child: CustomPaint(painter: _MonitorPainter()))),
              _Showcase(title: 'Power', child: SizedBox(
                  width: 220, height: 140,
                  child: CustomPaint(painter: _PowerPainter()))),
            ],
          )),
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
                onPressed: () => _go('https://gitlab.com/HttpAnimations/fnaf-flutter/-/releases/${r['tag_name']}'),
                child: const Text('Download'),
              ),
            )),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => _go('https://gitlab.com/HttpAnimations/fnaf-flutter/-/releases'),
            child: const Text('All releases on GitLab'),
          ),
        ]),
      ),
    );
  }
}

class _Showcase extends StatelessWidget {
  final String title;
  final Widget child;
  const _Showcase({required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(borderRadius: BorderRadius.circular(8), child: child),
        const SizedBox(height: 4),
        Text(title, style: Theme.of(context).textTheme.labelMedium),
      ]);
}

class _OfficePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF1A1A22));
    final desk = Paint()..color = const Color(0xFF3A2E22);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.3, size.height * 0.62, size.width * 0.4, size.height * 0.38), desk);
    final door = Paint()..color = const Color(0xFF2E2E38);
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.15, size.width * 0.1, size.height * 0.6), door);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.9, size.height * 0.15, size.width * 0.1, size.height * 0.6), door);
    final mon = Paint()..color = const Color(0xFF22382E);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.38, size.height * 0.3, size.width * 0.24, size.height * 0.22), mon);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.4, size.height * 0.33, size.width * 0.2, size.height * 0.16), Paint()..color = const Color(0xFF4F8F6B));
    final fan = Paint()..color = const Color(0xFF555A66)..style = PaintingStyle.stroke..strokeWidth = 3;
    final cx = size.width * 0.5, cy = size.height * 0.74, r = size.height * 0.13;
    canvas.drawCircle(Offset(cx, cy), r, fan);
    for (var i = 0; i < 3; i++) {
      final a = i * 2.094;
      canvas.drawLine(Offset(cx, cy),
          Offset(cx + r * 0.9 * _cos(a), cy + r * 0.9 * _sin(a)), fan);
    }
    canvas.drawRect(Rect.fromLTWH(size.width * 0.62, size.height * 0.66, size.width * 0.07, size.height * 0.2),
        Paint()..color = const Color(0xFF42332B));
  }
  double _cos(double a) => [1.0, -0.5, -0.5][(a / 2.094).round() % 3];
  double _sin(double a) => [0.0, 0.866, -0.866][(a / 2.094).round() % 3];
  @override
  bool shouldRepaint(_) => false;
}

class _MonitorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF0B0B10));
    final cell = Paint()..color = const Color(0xFF232A35);
    final sel = Paint()..color = const Color(0xFF3E5C46);
    final rooms = [(0.05, 0.08), (0.3, 0.08), (0.05, 0.38), (0.3, 0.38), (0.05, 0.68), (0.3, 0.68), (0.62, 0.08), (0.62, 0.38), (0.62, 0.68)];
    for (var i = 0; i < rooms.length; i++) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(size.width * rooms[i].$1, size.height * rooms[i].$2,
                  size.width * 0.2, size.height * 0.22),
              const Radius.circular(3)),
          i == 4 ? sel : cell);
      canvas.drawRect(
          Rect.fromLTWH(size.width * rooms[i].$1 + 4, size.height * rooms[i].$2 + 4,
              size.width * 0.1, 8),
          Paint()..color = const Color(0xFF525E70));
    }
    final cam = Paint()..color = const Color(0xFFB04141);
    canvas.drawCircle(Offset(size.width * 0.87, size.height * 0.78), 7, cam);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.84, size.height * 0.78 - 3, 6, 6), cam);
  }
  @override
  bool shouldRepaint(_) => false;
}

class _PowerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF101016));
    const start = 1.5708 * 1.5;
    final total = 1.5708 * 2;
    for (var i = 0; i < 5; i++) {
      final c = i < 3 ? const Color(0xFF55B45C) : const Color(0xFF2C3B31);
      canvas.drawArc(
          Rect.fromCircle(center: Offset(size.width * 0.5, size.height * 0.56), radius: size.height * 0.4),
          start - i * total / 5 - 0.08, total / 5 - 0.16, false,
          Paint()
            ..color = c
            ..style = PaintingStyle.stroke
            ..strokeWidth = 12
            ..strokeCap = StrokeCap.round);
    }
    final bar = Paint()..color = const Color(0xFF8F9430);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.28, size.height * 0.82, size.width * 0.28, 8), bar);
  }
  @override
  bool shouldRepaint(_) => false;
}
