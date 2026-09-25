class NewsItem {
  final int id;
  final String title;
  final String category; // tech | spazio | aerei | f1
  final String excerpt;
  final String body;
  final String imageUrl;
  final String publishedAt;

  NewsItem({
    required this.id,
    required this.title,
    required this.category,
    required this.excerpt,
    required this.body,
    required this.imageUrl,
    required this.publishedAt,
  });

  factory NewsItem.fromJson(Map<String, dynamic> j) => NewsItem(
        id: (j['id'] as num).toInt(),
        title: j['title'] ?? '',
        category: j['category'] ?? 'tech',
        excerpt: j['excerpt'] ?? '',
        body: j['body'] ?? '',
        imageUrl: j['image_url'] ?? '',
        publishedAt: j['published_at'] ?? '',
      );
}
