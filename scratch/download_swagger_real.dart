import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse('http://clinicbook.runasp.net/swagger/v1/swagger.json'));
    final response = await request.close();
    final stringData = await response.transform(utf8.decoder).join();
    final json = jsonDecode(stringData);
    final paths = json['paths'] as Map<String, dynamic>;
    
    print('--- Admin/PatientApi endpoints ---');
    for (var key in paths.keys) {
      if (key.contains('PatientApi')) {
        print(key);
      }
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
