import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../models/f1.dart';

/// Sezione segreta: unlock via PIN (server) -> secret JWT salvato localmente,
/// lettura foto/messaggi con Bearer. Supporto biometria via local_auth nelle screen.
class SecretService {
  static const _kToken = 'jd_secret_token';

  static Future<String> unlock(String pin) async {
    final base = await ApiService.baseUrl();
    final r = await http
        .post(Uri.parse('$base/api/secret/unlock'),
            headers: {'Content-Type': 'application/json'}, body: jsonEncode({'pin': pin}))
        .timeout(const Duration(seconds: 10));
    if (r.statusCode != 200) throw Exception('PIN errato');
    final token = (jsonDecode(r.body)['token'] as String);
    final p = await SharedPreferences.getInstance();
    await p.setString(_kToken, token);
    return token;
  }

  static Future<String?> token() async =>
      (await SharedPreferences.getInstance()).getString(_kToken);

  static Future<void> lock() async =>
      (await SharedPreferences.getInstance()).remove(_kToken);

  static Future<List<SecretPhoto>> photos() async {
    final base = await ApiService.baseUrl();
    final t = await token();
    if (t == null) throw Exception('Bloccato: inserisci il PIN');
    final r = await http.get(Uri.parse('$base/api/secret/photos'),
        headers: {'Authorization': 'Bearer $t'}).timeout(const Duration(seconds: 12));
    if (r.statusCode != 200) throw Exception('HTTP ${r.statusCode}');
    return (jsonDecode(r.body) as List)
        .map((e) => SecretPhoto.fromJson(e as Map<String, dynamic>, base))
        .toList();
  }

  static Future<List<SecretMessage>> messages() async {
    final base = await ApiService.baseUrl();
    final t = await token();
    if (t == null) throw Exception('Bloccato: inserisci il PIN');
    final r = await http.get(Uri.parse('$base/api/secret/messages'),
        headers: {'Authorization': 'Bearer $t'}).timeout(const Duration(seconds: 12));
    if (r.statusCode != 200) throw Exception('HTTP ${r.statusCode}');
    return (jsonDecode(r.body) as List)
        .map((e) => SecretMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
