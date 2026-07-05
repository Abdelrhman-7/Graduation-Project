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
    
    print('--- GetAllDoctors Response Schema ---');
    final getDocs = paths['/api/Admin/DoctorApi/GetAllDoctors'];
    print(JsonEncoder.withIndent('  ').convert(getDocs));

    print('\n--- GetAllPatients Response Schema ---');
    final getPats = paths['/api/Admin/PatientApi/GetAllPatients'];
    print(JsonEncoder.withIndent('  ').convert(getPats));

    print('\n--- Schema definitions keys ---');
    final components = json['components'];
    if (components != null && components['schemas'] != null) {
      final schemas = components['schemas'] as Map<String, dynamic>;
      print('Schemas keys: ${schemas.keys.toList()}');
    }

  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
