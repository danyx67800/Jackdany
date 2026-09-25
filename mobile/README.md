# App mobile Jack Dany (Flutter)

Vedi README root per quickstart. Configura il backend in **Impostazioni** (IP Umbrel / Tailscale).

- Splash: `lib/screens/splash_screen.dart` (Hero `jd-logo` → top bar).
- Easter egg: 5 tap sul logo in `lib/widgets/top_bar.dart` → `/secret` (PIN + biometria).
- Liquid Glass: `lib/widgets/liquid_glass.dart` (`GlassCard` + `BackdropFilter`).
- F1: `lib/services/f1_service.dart` (OpenF1 → fallback Jolpica).
