import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

bool get isDesktop =>
    !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

class WindowButtons {
  static Future<void> close() => windowManager.close();
  static Future<void> minimize() => windowManager.minimize();
  static Future<void> maximize() async {
    if (await windowManager.isMaximized()) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
  }
}

class MacTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool dark;
  const MacTopBar({super.key, required this.title, this.dark = true});

  @override
  Size get preferredSize => const Size.fromHeight(40);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: WindowButtons.maximize,
      child: DragToMoveArea(
        child: Container(
          height: 40,
          color: dark ? const Color(0xFF1E1E1E) : const Color(0xFFECECEC),
          child: Row(
            children: [
              const SizedBox(width: 12),
              _TrafficButton(color: const Color(0xFFFF5F57), glyph: '×', onTap: WindowButtons.close),
              _TrafficButton(color: const Color(0xFFFEBC2E), glyph: '−', onTap: WindowButtons.minimize),
              _TrafficButton(color: const Color(0xFF28C840), glyph: '+', onTap: WindowButtons.maximize),
              Expanded(
                child: Center(
                  child: Text(title,
                      style: TextStyle(
                          color: dark ? Colors.white70 : Colors.black54,
                          fontSize: 13)),
                ),
              ),
              const SizedBox(width: 76),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrafficButton extends StatefulWidget {
  final Color color;
  final String glyph;
  final Future<void> Function() onTap;
  const _TrafficButton({required this.color, required this.glyph, required this.onTap});

  @override
  State<_TrafficButton> createState() => _TrafficButtonState();
}

class _TrafficButtonState extends State<_TrafficButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 12, height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
          child: _hover
              ? Center(child: Text(widget.glyph,
                  style: const TextStyle(fontSize: 9, height: 1, color: Colors.black54)))
              : null,
        ),
      ),
    );
  }
}
