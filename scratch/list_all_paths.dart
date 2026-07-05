import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient()
    ..badCertificateCallback = (cert, host, port) => true;
  final request = await client.getUrl(
    Uri.parse('http://clinicbook.runasp.net/swagger/v1/swagger.json'),
  );
  final response = await request.close();
  final stringData = await response.transform(utf8.decoder).join();
  final json = jsonDecode(stringData);
  final paths = (json['paths'] as Map<String, dynamic>).keys.toList()..sort();
  for (final p in paths) {
    print(p);
  }
  client.close();
}
