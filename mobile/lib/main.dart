import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/secret_gate_screen.dart';
import 'screens/settings_screen.dart';

void main() => runApp(const JackDanyApp());

class JackDanyApp extends StatelessWidget {
  const JackDanyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jack Dany',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F9BFF), brightness: Brightness.dark),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/home': (_) => const HomeScreen(),
        '/secret': (_) => const SecretGateScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
    );
  }
}
