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
  final paths = json['paths'] as Map<String, dynamic>;
  for (final key in paths.keys) {
    if (key.toLowerCase().contains('schedule')) {
      print('========================================');
      print('Path: $key');
      final methods = paths[key] as Map<String, dynamic>;
      for (final method in methods.keys) {
        print('  Method: ${method.toUpperCase()}');
        final details = methods[method] as Map<String, dynamic>;
        print('    Parameters: ${details['parameters']}');
        if (details.containsKey('requestBody')) {
          print('    RequestBody: ${details['requestBody']}');
        }
      }
    }
  }
  client.close();
}
