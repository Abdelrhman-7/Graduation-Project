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
    
    print('--- Edit Profile Paths ---');
    paths.forEach((key, value) {
      if (key.toLowerCase().contains('editprofile') || key.toLowerCase().contains('profileapi')) {
        print('Path: $key');
        print(JsonEncoder.withIndent('  ').convert(value));
      }
    });

  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
