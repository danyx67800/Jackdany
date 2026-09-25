import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/liquid_glass.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _url = TextEditingController();
  String _msg = '';

  @override
  void initState() {
    super.initState();
    ApiService.baseUrl().then((v) => _url.text = v);
  }

  @override
  Widget build(BuildContext context) {
    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: const Text('Impostazioni')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: GlassCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Backend Umbrel', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text('IP locale, Tailscale o HTTPS. Es: http://umbrel.local:3000',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 10),
              TextField(controller: _url, decoration: const InputDecoration(hintText: 'http://umbrel.local:3000')),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    await ApiService.setBaseUrl(_url.text);
                    try {
                      final s = await ApiService.fetchSettings();
                      setState(() => _msg = 'Connesso! App: ${s['app_name']}');
                    } catch (e) {
                      setState(() => _msg = 'Salvato, ma connessione fallita: $e');
                    }
                  },
                  child: const Text('Salva e verifica'),
                ),
              ),
              if (_msg.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_msg)),
            ]),
          ),
        ),
      ),
    );
  }
}
