import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient()
    ..badCertificateCallback = (cert, host, port) => true;

  try {
    final request = await client.getUrl(Uri.parse('http://clinicbook.runasp.net/swagger/v1/swagger.json'));
    final response = await request.close();
    final stringData = await response.transform(utf8.decoder).join();
    final json = jsonDecode(stringData);
    final paths = json['paths'] as Map<String, dynamic>;
    
    print('Paths containing Toggle:');
    for (var key in paths.keys) {
      if (key.toLowerCase().contains('toggle') && key.toLowerCase().contains('lock')) {
        print('  $key');
        print(JsonEncoder.withIndent('    ').convert(paths[key]));
      }
    }

  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
