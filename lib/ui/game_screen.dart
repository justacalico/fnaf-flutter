import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../assets/asset_manifest.dart';
import '../assets/asset_store.dart';
import '../game/engine.dart';
import '../services/audio_service.dart';

class GameScreen extends StatefulWidget {
  final AssetStore assets;
  final int night;
  final bool fanMuted;
  final VoidCallback onWin;
  final VoidCallback onLose;
  final GameEngine? engine;
  const GameScreen({super.key, required this.assets, required this.night, required this.onWin, required this.onLose, this.fanMuted = false, this.engine});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameEngine e;
  late AudioService audio;
  Timer? timer;
  double pan = 0.5;
  int staticFrame = 0;
  bool jumpscaring = false;
  int scareFrame = 0;
  Timer? scareTimer;

  @override
  void initState() {
    super.initState();
    audio = AudioService(widget.assets.sounds);
    e = widget.engine ?? GameEngine(night: widget.night, events: _Events(this));
    if (widget.engine != null) e.events = _Events(this);
    timer = Timer.periodic(const Duration(milliseconds: 33), (_) {
      setState(() {
        e.tick(0.033);
        staticFrame = (staticFrame + 1) % Assets.staticNoise.length;
      });
    });
    if (!widget.fanMuted) audio.play(Assets.sndFan, loop: true, volume: 0.4);
    final call = NightConfig.phoneCall[widget.night.clamp(1, 6)];
    if (call.isNotEmpty) audio.play(call, volume: 0.9);
    audio.play(Assets.sndCold, loop: true, volume: 0.15);
  }

  @override
  void dispose() {
    timer?.cancel();
    scareTimer?.cancel();
    audio.dispose();
    super.dispose();
  }

  void _jumpscare(Animatronic a) {
    if (jumpscaring) return;
    jumpscaring = true;
    scareFrame = 0;
    audio.stopAll();
    audio.play(Assets.sndJumpscare, volume: 1.0);
    scareTimer = Timer.periodic(const Duration(milliseconds: 60), (t) {
      setState(() => scareFrame++);
      if (scareFrame > 24) {
        t.cancel();
        widget.onLose();
      }
    });
    setState(() {});
  }

  List<int> _scareFrames(Animatronic a) => switch (a) {
        Animatronic.bonnie => Assets.bonnieJumpscare,
        Animatronic.chica => Assets.chicaJumpscare,
        Animatronic.freddy => Assets.freddyJumpscare,
        Animatronic.foxy => Assets.foxyJumpscare,
      };

  Uint8List? _img(int h) => widget.assets.image(h);

  Widget _imgWidget(int? h, {BoxFit fit = BoxFit.cover, double? w, double? hgt}) {
    final d = h == null ? null : _img(h);
    if (d == null) return const SizedBox.shrink();
    return Image.memory(d, fit: fit, width: w, height: hgt, gaplessPlayback: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(builder: (context, c) {
        if (jumpscaring) return _buildScare();
        return MouseRegion(
          onHover: (ev) => setState(() => pan = (ev.position.dx / c.maxWidth).clamp(0.0, 1.0)),
          child: Stack(fit: StackFit.expand, children: [
            _buildOffice(),
            if (e.powerOut) Container(color: Colors.black.withValues(alpha: 0.85)),
            _buildDoorUI(),
            _buildCamUI(),
            _buildHud(),
          ]),
        );
      }),
    );
  }

  Widget _buildScare() {
    final frames = _scareFrames(e.jumpscareBy ?? Animatronic.freddy);
    final f = frames[scareFrame.clamp(0, frames.length - 1)];
    return Container(color: Colors.black, child: Center(child: _imgWidget(f, fit: BoxFit.contain)));
  }

  Widget _buildOffice() {
    final off = -pan * 320;
    return Stack(fit: StackFit.expand, children: [
      Positioned(
        left: off, top: 0, bottom: 0, width: 1600,
        child: _imgWidget(Assets.officeBase, fit: BoxFit.cover),
      ),
      Positioned(
        left: off, top: 0, height: 253, width: 1600,
        child: _imgWidget(Assets.ceilingLights, fit: BoxFit.fill),
      ),
      if (e.leftLight)
        Positioned(
          left: off + 40, top: 0, bottom: 0,
          child: _imgWidget(e.lightSeesLeft() ? Assets.bonnieAtDoor : Assets.doorLitEmpty, fit: BoxFit.contain),
        ),
      if (e.rightLight)
        Positioned(
          right: -off + 40, top: 0, bottom: 0,
          child: _imgWidget(e.lightSeesRight() ? Assets.chicaAtDoor : Assets.doorLitEmpty, fit: BoxFit.contain),
        ),
    ]);
  }

  Widget _doorButtons(bool left) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      _PanelBtn(label: 'DOOR', on: left ? e.leftDoorClosed : e.rightDoorClosed,
          activeColor: Colors.red,
          onTap: left ? e.toggleLeftDoor : e.toggleRightDoor),
      const SizedBox(height: 6),
      _PanelBtn(label: 'LIGHT', on: left ? e.leftLight : e.rightLight,
          activeColor: Colors.blue,
          onTap: () => setState(() {
            if (left) { e.leftLight = !e.leftLight; e.rightLight = false; }
            else { e.rightLight = !e.rightLight; e.leftLight = false; }
          })),
    ]);
  }

  Widget _buildDoorUI() {
    return Stack(children: [
      Positioned(left: 8, top: 140, child: _doorButtons(true)),
      Positioned(right: 8, top: 140, child: _doorButtons(false)),
      if (e.leftDoorClosed)
        Positioned(left: 46, top: 0, bottom: 0,
            child: _imgWidget(Assets.doorLeftClose.last, fit: BoxFit.fill, w: 120)),
      if (e.rightDoorClosed)
        Positioned(right: 46, top: 0, bottom: 0,
            child: _imgWidget(Assets.doorRightClose.last, fit: BoxFit.fill, w: 120)),
    ]);
  }

  Widget _buildHud() {
    return Stack(children: [
      Positioned(right: 12, top: 8, child: Text('${e.clockLabel} AM',
          style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'monospace'))),
      Positioned(left: 12, bottom: 8, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Power left: ${e.power.floor()}%',
            style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'monospace')),
        Row(children: [
          const Text('Usage: ', style: TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'monospace')),
          for (var i = 0; i < 5; i++)
            Container(width: 8, height: 16, margin: const EdgeInsets.symmetric(horizontal: 1),
                color: i < e.usageLevel ? Colors.green : Colors.grey[800]),
        ]),
      ])),
      Positioned(right: 12, bottom: 8, child: Text('Night ${widget.night}',
          style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'monospace'))),
      if (!e.powerOut)
        Positioned(
          left: 0, right: 0, bottom: 0, height: 90,
          child: GestureDetector(
            onTap: () => setState(e.toggleMonitor),
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
                      colors: [Colors.white24, Colors.transparent])),
              child: const Center(child: Icon(Icons.keyboard_arrow_up, color: Colors.white54, size: 36)),
            ),
          ),
        ),
    ]);
  }

  Widget _buildCamUI() {
    if (!e.monitorUp) return const SizedBox.shrink();
    final room = camRooms[e.currentCam];
    final occupants = room == null ? <Animatronic>{} : e.occupantsOf(room);
    final views = Assets.camViews[e.currentCam] ?? const [0];
    var idx = occupants.isEmpty ? 0 : views.length - 1;
    for (final a in occupants) {
      final occ = Assets.camOccupants[a.name];
      if (occ != null && occ.isNotEmpty) {
        idx = views.length - 1;
        break;
      }
    }
    final view = views[idx.clamp(0, views.length - 1)];
    final noise = _img(Assets.staticNoise[staticFrame]);
    final label = Assets.camLabels[e.currentCam];
    return Container(color: Colors.black, child: Stack(fit: StackFit.expand, children: [
      _imgWidget(view, fit: BoxFit.cover),
      if (noise != null)
        Opacity(opacity: 0.25, child: Image.memory(noise, fit: BoxFit.cover, width: double.infinity, height: double.infinity, gaplessPlayback: true)),
      _imgWidget(Assets.monitorFrame, fit: BoxFit.fill),
      if (label != null)
        Positioned(left: 12, top: 12, child: _imgWidget(label, fit: BoxFit.contain)),
      if (e.currentCam == 'cam6')
        const Center(child: Text('- CAMERA DISABLED -\nAUDIO ONLY', textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 20, fontFamily: 'monospace'))),
      Positioned(left: 0, right: 0, bottom: 0, height: 90,
        child: GestureDetector(onTap: () => setState(e.toggleMonitor),
          child: const Center(child: Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 36)))),
      _buildMap(),
    ]));
  }

  Widget _buildMap() {
    final map = _img(Assets.camMap);
    final buttons = <String, Offset>{
      'cam1a': const Offset(0.30, 0.15), 'cam1b': const Offset(0.30, 0.32),
      'cam5': const Offset(0.12, 0.22), 'cam7': const Offset(0.50, 0.32),
      'cam1c': const Offset(0.08, 0.52), 'cam3': const Offset(0.30, 0.60),
      'cam2a': const Offset(0.42, 0.55), 'cam2b': const Offset(0.42, 0.85),
      'cam4a': const Offset(0.62, 0.55), 'cam4b': const Offset(0.62, 0.85),
      'cam6': const Offset(0.55, 0.28),
    };
    return Positioned(right: 12, bottom: 100, child: SizedBox(width: 300, height: 240, child: Stack(children: [
      if (map != null) Opacity(opacity: 0.85, child: Image.memory(map, fit: BoxFit.contain)),
      ...buttons.entries.map((b) => Positioned(
        left: b.value.dx * 300, top: b.value.dy * 240,
        child: GestureDetector(
          key: Key('cambtn_${b.key}'),
          onTap: () => setState(() => e.selectCam(b.key)),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: e.currentCam == b.key ? Colors.green : Colors.black54,
              border: Border.all(color: Colors.white54),
            ),
            child: _imgWidget(Assets.camLabels[b.key] ?? Assets.camButton,
                fit: BoxFit.contain, w: 46),
          ),
        ))),
    ])));
  }
}

class _PanelBtn extends StatelessWidget {
  final String label;
  final bool on;
  final Color activeColor;
  final VoidCallback onTap;
  const _PanelBtn({required this.label, required this.on, required this.activeColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54, padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: on ? activeColor : Colors.black,
          border: Border.all(color: Colors.white70),
        ),
        child: Center(child: Text(label,
            style: TextStyle(color: on ? Colors.white : Colors.white70, fontSize: 10, fontFamily: 'monospace'))),
      ),
    );
  }
}

class _Events extends EngineEvents {
  final _GameScreenState s;
  _Events(this.s);
  @override
  void onJumpscare(Animatronic a) => s._jumpscare(a);
  @override
  void onNightWin() => s.widget.onWin();
  @override
  void onPowerOut() {
    s.audio.stopAll();
    s.audio.play(Assets.sndPowerDown, volume: 0.8);
  }
  @override
  void onDoorPound() => s.audio.play(Assets.sndDoorPound, volume: 0.9);
}
