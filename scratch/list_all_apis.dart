import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient()
    ..badCertificateCallback = (cert, host, port) => true;

  try {
    final request = await client.getUrl(
      Uri.parse('http://clinicbook.runasp.net/swagger/v1/swagger.json'),
    );
    final response = await request.close();
    final stringData = await response.transform(utf8.decoder).join();
    final json = jsonDecode(stringData);
    final paths = (json['paths'] as Map<String, dynamic>).keys.toList()..sort();

    print('=== ALL Doctor APIs ===');
    for (final p in paths) {
      if (p.toLowerCase().contains('/doctor/')) {
        print(p);
        final methods = json['paths'][p] as Map<String, dynamic>;
        for (final m in methods.keys) {
          print('  $m');
        }
      }
    }

    print('\n=== ALL Patient APIs ===');
    for (final p in paths) {
      if (p.toLowerCase().contains('/patient/')) {
        print(p);
        final methods = json['paths'][p] as Map<String, dynamic>;
        for (final m in methods.keys) {
          print('  $m');
        }
      }
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
