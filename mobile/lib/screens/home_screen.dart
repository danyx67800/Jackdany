import 'package:flutter/material.dart';
import '../models/news.dart';
import '../services/api_service.dart';
import '../widgets/liquid_glass.dart';
import '../widgets/top_bar.dart';
import 'news_detail_screen.dart';
import 'f1_dashboard_screen.dart';

const _cats = [
  {'id': 'tech', 'label': 'Tech', 'icon': Icons.memory},
  {'id': 'spazio', 'label': 'Spazio', 'icon': Icons.rocket_launch},
  {'id': 'aerei', 'label': 'Aerei', 'icon': Icons.flight},
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  int _nav = 0; // 0 news, 1 F1

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: JackTopBar(
          onSecretTrigger: () => Navigator.of(context).pushNamed('/secret'),
          onSettings: () => Navigator.of(context).pushNamed('/settings'),
        ),
        body: SafeArea(
          child: _nav == 0 ? _newsBody() : const F1DashboardScreen(embed: true),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(12),
          child: GlassCard(
            radius: 24,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              currentIndex: _nav,
              onTap: (i) => setState(() => _nav = i),
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white60,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'Notizie'),
                BottomNavigationBarItem(icon: Icon(Icons.sports_motorsports), label: 'Formula 1'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _newsBody() {
    return Column(
      children: [
        TabBar(
          controller: _tabs,
          tabs: _cats.map((c) => Tab(icon: Icon(c['icon'] as IconData), text: c['label'] as String)).toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: _cats.map((c) => NewsList(category: c['id'] as String)).toList(),
          ),
        ),
      ],
    );
  }
}

class NewsList extends StatefulWidget {
  final String category;
  const NewsList({super.key, required this.category});
  @override
  State<NewsList> createState() => _NewsListState();
}

class _NewsListState extends State<NewsList> {
  late Future<List<NewsItem>> _f;
  @override
  void initState() {
    super.initState();
    _f = ApiService.fetchNews(category: widget.category);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => setState(() => _f = ApiService.fetchNews(category: widget.category)),
      child: FutureBuilder<List<NewsItem>>(
        future: _f,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: GlassCard(
                child: Text('Errore: ${snap.error}\nControlla il backend Umbrel in Impostazioni.',
                    textAlign: TextAlign.center),
              ),
            );
          }
          final items = snap.data ?? [];
          if (items.isEmpty) return const Center(child: Text('Nessuna notizia', style: TextStyle(color: Colors.white70)));
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final n = items[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => NewsDetailScreen(item: n)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (n.imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(n.imageUrl, height: 160, width: double.infinity, fit: BoxFit.cover),
                        ),
                      Text(n.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 6),
                      Text(n.excerpt, style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
