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
  final schemas = json['components']['schemas'] as Map<String, dynamic>;
  print('All schema keys:');
  print(schemas.keys.toList());
  client.close();
}
