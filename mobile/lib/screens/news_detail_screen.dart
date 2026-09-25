import 'package:flutter/material.dart';
import '../models/news.dart';
import '../widgets/liquid_glass.dart';

class NewsDetailScreen extends StatelessWidget {
  final NewsItem item;
  const NewsDetailScreen({super.key, required this.item});
  @override
  Widget build(BuildContext context) {
    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.category.toUpperCase(),
                      style: const TextStyle(letterSpacing: 2, color: Colors.lightBlueAccent, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(item.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text(item.publishedAt, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (item.imageUrl.isNotEmpty)
              ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(item.imageUrl)),
            const SizedBox(height: 12),
            GlassCard(child: Text(item.body.isEmpty ? item.excerpt : item.body, style: const TextStyle(height: 1.5))),
          ],
        ),
      ),
    );
  }
}
