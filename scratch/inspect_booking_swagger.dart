import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient()..badCertificateCallback = (_, __, ___) => true;
  final req = await client.getUrl(
    Uri.parse('http://clinicbook.runasp.net/swagger/v1/swagger.json'),
  );
  final res = await req.close();
  final json = jsonDecode(await res.transform(utf8.decoder).join());
  final paths = json['paths'] as Map<String, dynamic>;

  for (final p in paths.keys) {
    if (p.toLowerCase().contains('book') ||
        p.toLowerCase().contains('appoint') ||
        p.toLowerCase().contains('notif')) {
      print(p);
      print(JsonEncoder.withIndent('  ').convert(paths[p]));
      print('');
    }
  }
  client.close();
}
