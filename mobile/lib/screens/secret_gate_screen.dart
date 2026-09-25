import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../services/secret_service.dart';
import '../widgets/liquid_glass.dart';
import 'secret_view_screen.dart';

/// Gate: PIN (server) + biometria opzionale.
class SecretGateScreen extends StatefulWidget {
  const SecretGateScreen({super.key});
  @override
  State<SecretGateScreen> createState() => _SecretGateScreenState();
}

class _SecretGateScreenState extends State<SecretGateScreen> {
  final _pin = TextEditingController();
  bool _busy = false;
  String? _err;

  Future<void> _tryBio() async {
    final auth = LocalAuthentication();
    try {
      final ok = await auth.authenticate(localizedReason: 'Sblocca la sezione segreta');
      if (ok && mounted) {
        // Se esiste già un token secret, entra; altrimenti chiedi comunque il PIN la prima volta.
        final t = await SecretService.token();
        if (t != null) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const SecretViewScreen()));
        } else {
          setState(() => _err = 'Prima volta: inserisci il PIN, poi userai la biometria.');
        }
      }
    } on PlatformException {
      setState(() => _err = 'Biometria non disponibile su questo dispositivo.');
    }
  }

  Future<void> _unlock() async {
    setState(() { _busy = true; _err = null; });
    try {
      await SecretService.unlock(_pin.text.trim());
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const SecretViewScreen()));
      }
    } catch (e) {
      setState(() => _err = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: const Text('Area riservata')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: GlassCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline, size: 48),
                  const SizedBox(height: 12),
                  const Text('Sezione segreta', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                  const SizedBox(height: 8),
                  const Text('Inserisci il PIN per vedere foto e messaggi privati.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _pin,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    decoration: const InputDecoration(hintText: 'PIN'),
                    onSubmitted: (_) => _unlock(),
                  ),
                  if (_err != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_err!, style: const TextStyle(color: Colors.redAccent))),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(onPressed: _busy ? null : _unlock, child: Text(_busy ? '...' : 'Sblocca')),
                  ),
                  TextButton.icon(onPressed: _tryBio, icon: const Icon(Icons.fingerprint), label: const Text('Usa biometria')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
