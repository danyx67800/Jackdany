import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/news.dart';

/// Base URL del backend Umbrel: configurabile (IP locale / Tailscale / HTTPS).
/// Default: http://umbrel.local:3000 — modificabile dalla schermata Impostazioni.
class ApiService {
  static const _kBaseUrl = 'jd_base_url';
  static const defaultBaseUrl = 'http://umbrel.local:3000';

  static Future<String> baseUrl() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kBaseUrl) ?? defaultBaseUrl;
  }

  static Future<void> setBaseUrl(String v) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kBaseUrl, v.trim().replaceAll(RegExp(r'/$'), ''));
  }

  static Future<List<NewsItem>> fetchNews({String? category}) async {
    final base = await baseUrl();
    final uri = Uri.parse('$base/api/news').replace(
      queryParameters: category == null ? null : {'category': category},
    );
    final r = await http.get(uri).timeout(const Duration(seconds: 12));
    if (r.statusCode != 200) throw Exception('News HTTP ${r.statusCode}');
    final List list = jsonDecode(r.body) as List;
    return list.map((e) => NewsItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<Map<String, dynamic>> fetchSettings() async {
    final base = await baseUrl();
    final r = await http.get(Uri.parse('$base/api/settings')).timeout(const Duration(seconds: 10));
    if (r.statusCode != 200) throw Exception('Settings HTTP ${r.statusCode}');
    return jsonDecode(r.body) as Map<String, dynamic>;
  }
}
