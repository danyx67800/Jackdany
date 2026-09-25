import 'package:flutter/material.dart';

/// TopBar con logo in alto a sinistra.
/// I 5 tap consecutivi sul logo (entro 2.5s) aprono la route segreta.
class JackTopBar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback onSecretTrigger;
  final VoidCallback? onSettings;
  const JackTopBar({super.key, required this.onSecretTrigger, this.onSettings});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  State<JackTopBar> createState() => _JackTopBarState();
}

class _JackTopBarState extends State<JackTopBar> {
  int _taps = 0;
  DateTime? _firstTap;

  void _onLogoTap() {
    final now = DateTime.now();
    if (_firstTap == null || now.difference(_firstTap!).inMilliseconds > 2500) {
      _firstTap = now;
      _taps = 1;
    } else {
      _taps++;
    }
    if (_taps >= 5) {
      _taps = 0;
      _firstTap = null;
      widget.onSecretTrigger();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 8,
      title: Row(
        children: [
          GestureDetector(
            onTap: _onLogoTap,
            child: Hero(
              tag: 'jd-logo',
              child: Image.asset('assets/logo.png', width: 40, height: 40),
            ),
          ),
          const SizedBox(width: 10),
          const Text('Jack Dany', style: TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
      actions: [
        if (widget.onSettings != null)
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: widget.onSettings),
      ],
    );
  }
}
