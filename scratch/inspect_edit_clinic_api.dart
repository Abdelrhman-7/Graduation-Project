import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient()..badCertificateCallback = (_, __, ___) => true;
  try {
    final req = await client.getUrl(
      Uri.parse('http://clinicbook.runasp.net/swagger/v1/swagger.json'),
    );
    final res = await req.close();
    final json = jsonDecode(await res.transform(utf8.decoder).join());
    final paths = json['paths'] as Map<String, dynamic>;

    final targetPath1 = paths.keys.firstWhere(
      (k) => k.toLowerCase().contains('scheduleapi/createschedule'),
      orElse: () => '',
    );
    if (targetPath1.isNotEmpty) {
      print('=== $targetPath1 ===');
      print(JsonEncoder.withIndent('  ').convert(paths[targetPath1]));
    }

    final targetPath2 = paths.keys.firstWhere(
      (k) => k.toLowerCase().contains('scheduleapi/editschedule'),
      orElse: () => '',
    );
    if (targetPath2.isNotEmpty) {
      print('=== $targetPath2 ===');
      print(JsonEncoder.withIndent('  ').convert(paths[targetPath2]));
    }

  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
