import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient()..badCertificateCallback = (_, __, ___) => true;
  final req = await client.getUrl(
    Uri.parse('http://clinicbook.runasp.net/swagger/v1/swagger.json'),
  );
  final res = await req.close();
  final json = jsonDecode(await res.transform(utf8.decoder).join());
  final paths = (json['paths'] as Map<String, dynamic>).keys;
  for (final p in paths) {
    final lower = p.toLowerCase();
    if (lower.contains('book') ||
        lower.contains('appoint') ||
        lower.contains('pending') ||
        lower.contains('accept') ||
        lower.contains('reject')) {
      print(p);
    }
  }
  client.close();
}
