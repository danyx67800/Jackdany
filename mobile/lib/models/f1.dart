class DriverStanding {
  final int position;
  final String name;
  final String team;
  final int points;
  final String colorHex;

  DriverStanding({required this.position, required this.name, required this.team, required this.points, required this.colorHex});
}

class F1Session {
  final String key;
  final String name; // Race, Qualifying...
  final String location;
  final String dateStart;
  final String sessionName;

  F1Session({required this.key, required this.name, required this.location, required this.dateStart, required this.sessionName});

  factory F1Session.fromJson(Map<String, dynamic> j) => F1Session(
        key: '${j['session_key']}',
        name: j['meeting_name'] ?? j['location'] ?? '',
        location: j['location'] ?? '',
        dateStart: j['date_start'] ?? '',
        sessionName: j['session_name'] ?? '',
      );
}

class SecretMessage {
  final int id;
  final String title;
  final String body;
  SecretMessage({required this.id, required this.title, required this.body});
  factory SecretMessage.fromJson(Map<String, dynamic> j) =>
      SecretMessage(id: (j['id'] as num).toInt(), title: j['title'] ?? '', body: j['body'] ?? '');
}

class SecretPhoto {
  final int id;
  final String title;
  final String imageUrl;
  SecretPhoto({required this.id, required this.title, required this.imageUrl});
  factory SecretPhoto.fromJson(Map<String, dynamic> j, String baseUrl) => SecretPhoto(
        id: (j['id'] as num).toInt(),
        title: j['title'] ?? '',
        imageUrl: j['image_url']?.toString().startsWith('http') == true
            ? j['image_url']
            : '$baseUrl${j['image_url']}',
      );
}
