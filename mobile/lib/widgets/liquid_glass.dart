import 'dart:ui';
import 'package:flutter/material.dart';

/// Liquid Glass (stile iOS): vetro smerigliato con blur, trasparenze e bordo luminoso.
/// Su iOS usa il blur nativo (BackdropFilter ~ UIVisualEffectView), su Android fallback identico.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const GlassCard({super.key, required this.child, this.radius = 20, this.padding = const EdgeInsets.all(16), this.onTap});

  @override
  Widget build(BuildContext context) {
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Colors.white.withOpacity(0.22), Colors.white.withOpacity(0.06)],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.28), width: 1.2),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 24, offset: const Offset(0, 10))],
          ),
          child: child,
        ),
      ),
    );
    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, child: card);
  }
}

/// Sfondo adattivo: gradiente scuro elegante che esalta il glass.
class GlassBackground extends StatelessWidget {
  final Widget child;
  const GlassBackground({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF0B1220), Color(0xFF12233F), Color(0xFF0B1220)],
          ),
        ),
        child: child,
      );
}
