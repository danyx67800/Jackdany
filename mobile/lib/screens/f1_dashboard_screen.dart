import 'package:flutter/material.dart';
import '../models/news.dart';
import '../services/api_service.dart';
import '../services/f1_service.dart';
import '../models/f1.dart';
import '../widgets/liquid_glass.dart';

/// Dashboard F1: notizie F1 (dal backend) + dati live OpenF1/Jolpica.
class F1DashboardScreen extends StatefulWidget {
  final bool embed;
  const F1DashboardScreen({super.key, this.embed = false});
  @override
  State<F1DashboardScreen> createState() => _F1DashboardScreenState();
}

class _F1DashboardScreenState extends State<F1DashboardScreen> {
  late Future<List<DriverStanding>> _standings;
  late Future<List<F1Session>> _sessions;
  late Future<List<NewsItem>> _news;

  @override
  void initState() {
    super.initState();
    _standings = F1Service.driverStandings();
    _sessions = F1Service.sessions2026();
    _news = ApiService.fetchNews(category: 'f1');
  }

  @override
  Widget build(BuildContext context) {
    final body = RefreshIndicator(
      onRefresh: () async => setState(() {
        _standings = F1Service.driverStandings();
        _sessions = F1Service.sessions2026();
        _news = ApiService.fetchNews(category: 'f1');
      }),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Text('Classifica piloti', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 8),
          FutureBuilder<List<DriverStanding>>(
            future: _standings,
            builder: (_, s) {
              if (!s.hasData) return const GlassCard(child: Center(child: CircularProgressIndicator()));
              if (s.hasError) return GlassCard(child: Text('F1 non disponibile: ${s.error}'));
              return GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: s.data!.take(10).map((d) => ListTile(
                        leading: CircleAvatar(child: Text('${d.position}')),
                        title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(d.team),
                        trailing: Text('${d.points} pt', style: const TextStyle(fontWeight: FontWeight.w800)),
                      )).toList(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text('Calendario 2026 (sessioni)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 8),
          FutureBuilder<List<F1Session>>(
            future: _sessions,
            builder: (_, s) {
              if (!s.hasData) return const GlassCard(child: Center(child: CircularProgressIndicator()));
              final items = s.data!.reversed.take(8).toList();
              return GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: items.map((e) => ListTile(
                        title: Text('${e.location} — ${e.sessionName}'),
                        subtitle: Text(e.dateStart),
                      )).toList(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text('Notizie F1 dal tuo Umbrel', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 8),
          FutureBuilder<List<NewsItem>>(
            future: _news,
            builder: (_, s) {
              final items = s.data ?? [];
              if (items.isEmpty) return const GlassCard(child: Text('Nessuna notizia F1 sul backend.'));
              return Column(
                children: items.map((n) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GlassCard(child: Text(n.title, style: const TextStyle(fontWeight: FontWeight.w700))),
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
    if (widget.embed) return body;
    return GlassBackground(
      child: Scaffold(backgroundColor: Colors.transparent, appBar: AppBar(title: const Text('Formula 1'), backgroundColor: Colors.transparent), body: body),
    );
  }
}
