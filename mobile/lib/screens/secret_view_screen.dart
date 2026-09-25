import 'package:flutter/material.dart';
import '../models/f1.dart';
import '../services/secret_service.dart';
import '../widgets/liquid_glass.dart';

class SecretViewScreen extends StatefulWidget {
  const SecretViewScreen({super.key});
  @override
  State<SecretViewScreen> createState() => _SecretViewScreenState();
}

class _SecretViewScreenState extends State<SecretViewScreen> {
  late Future<List<SecretPhoto>> _photos;
  late Future<List<SecretMessage>> _msgs;

  @override
  void initState() {
    super.initState();
    _photos = SecretService.photos();
    _msgs = SecretService.messages();
  }

  @override
  Widget build(BuildContext context) {
    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent, elevation: 0, title: const Text('Solo per te'),
          actions: [
            IconButton(
              icon: const Icon(Icons.lock),
              onPressed: () async { await SecretService.lock(); if (mounted) Navigator.of(context).pop(); },
            )
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            const Text('Foto', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(height: 8),
            FutureBuilder<List<SecretPhoto>>(
              future: _photos,
              builder: (_, s) {
                if (!s.hasData) return const GlassCard(child: Center(child: CircularProgressIndicator()));
                if (s.data!.isEmpty) return const GlassCard(child: Text('Nessuna foto.'));
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
                  itemCount: s.data!.length,
                  itemBuilder: (_, i) {
                    final p = s.data![i];
                    return GlassCard(
                      padding: EdgeInsets.zero,
                      child: Column(children: [
                        Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), child: Image.network(p.imageUrl, fit: BoxFit.cover, width: double.infinity))),
                        Padding(padding: const EdgeInsets.all(8), child: Text(p.title)),
                      ]),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            const Text('Messaggi', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(height: 8),
            FutureBuilder<List<SecretMessage>>(
              future: _msgs,
              builder: (_, s) {
                if (!s.hasData) return const GlassCard(child: Center(child: CircularProgressIndicator()));
                if (s.data!.isEmpty) return const GlassCard(child: Text('Nessun messaggio.'));
                return Column(
                  children: s.data!.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(m.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text(m.body, style: const TextStyle(height: 1.5)),
                    ])),
                  )).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
