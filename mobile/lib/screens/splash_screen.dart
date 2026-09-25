import 'package:flutter/material.dart';

/// Splash: logo centrato -> animazione fluida verso l'alto a sinistra (top bar).
/// Usa Hero(tag 'jd-logo') per la transizione condivisa con la Home.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;
  Alignment _align = Alignment.center;
  double _logoSize = 140;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _scale = CurvedAnimation(parent: _c, curve: Curves.easeInOut);
    _c.forward();
    // Dopo la pausa, anima verso top-left e naviga in Home
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      setState(() {
        _align = Alignment.topLeft;
        _logoSize = 40;
      });
      Future.delayed(const Duration(milliseconds: 750), () {
        if (mounted) Navigator.of(context).pushReplacementNamed('/home');
      });
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF0B1220), Color(0xFF12233F)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AnimatedAlign(
              alignment: _align,
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeInOutCubic,
              child: ScaleTransition(
                scale: _scale,
                child: Hero(
                  tag: 'jd-logo',
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeInOutCubic,
                    width: _logoSize,
                    height: _logoSize,
                    child: Image.asset('assets/logo.png'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
