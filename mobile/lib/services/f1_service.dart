import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/f1.dart';

/// Dati F1: OpenF1 (gratuito, storico dal 2023, no key) con fallback Jolpica/Ergast.
/// OpenF1 docs: https://openf1.org/docs
class F1Service {
  static const _openf1 = 'https://api.openf1.org/v1';

  static Future<List<DriverStanding>> driverStandings() async {
    // 1) Tenta OpenF1: ultima sessione Race -> championship_drivers
    try {
      final sessions = await _get('$_openf1/sessions?session_name=Race&year=2026');
      if (sessions.isNotEmpty) {
        final key = sessions.last['session_key'];
        final champ = await _get('$_openf1/championship_drivers?session_key=$key');
        if (champ.isNotEmpty) {
          final drivers = await _get('$_openf1/drivers?session_key=$key');
          final byNum = {for (final d in drivers) '${d['driver_number']}': d};
          final out = <DriverStanding>[];
          for (final c in champ) {
            final d = byNum['${c['driver_number']}'] ?? {};
            out.add(DriverStanding(
              position: (c['position'] as num?)?.toInt() ?? 0,
              name: d['full_name'] ?? 'Driver ${c['driver_number']}',
              team: d['team_name'] ?? '',
              points: (c['points'] as num?)?.toInt() ?? 0,
              colorHex: d['team_colour'] ?? '2F9BFF',
            ));
          }
          out.sort((a, b) => a.position.compareTo(b.position));
          if (out.isNotEmpty) return out;
        }
      }
    } catch (_) {/* fallback sotto */}

    // 2) Fallback Jolpica Ergast
    final r = await http
        .get(Uri.parse('https://api.jolpi.ca/ergast/f1/2026/driverStandings.json'))
        .timeout(const Duration(seconds: 12));
    if (r.statusCode != 200) throw Exception('F1 HTTP ${r.statusCode}');
    final lists = (jsonDecode(r.body)['MRData']['StandingsTable']['StandingsLists'] as List);
    if (lists.isEmpty) return [];
    final standings = lists.first['DriverStandings'] as List;
    return standings.map((s) {
      final d = s['Driver'];
      return DriverStanding(
        position: int.tryParse('${s['position']}') ?? 0,
        name: '${d['givenName']} ${d['familyName']}',
        team: (s['Constructors'] as List).isNotEmpty ? s['Constructors'][0]['name'] : '',
        points: int.tryParse('${s['points']}'.split('.').first) ?? 0,
        colorHex: '2F9BFF',
      );
    }).toList();
  }

  static Future<List<F1Session>> sessions2026() async {
    final list = await _get('$_openf1/sessions?year=2026');
    return list.map((e) => F1Session.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<List<dynamic>> _get(String url) async {
    final r = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 12));
    if (r.statusCode != 200) throw Exception('OpenF1 HTTP ${r.statusCode}');
    final body = jsonDecode(r.body);
    return body is List ? body : [];
  }
}
