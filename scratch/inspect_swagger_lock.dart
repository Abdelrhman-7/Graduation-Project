import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient()
    ..badCertificateCallback = (cert, host, port) => true;

  try {
    print('Downloading swagger.json...');
    final request = await client.getUrl(Uri.parse('http://clinicbook.runasp.net/swagger/v1/swagger.json'));
    final response = await request.close();
    final stringData = await response.transform(utf8.decoder).join();
    final json = jsonDecode(stringData);
    final paths = json['paths'] as Map<String, dynamic>;
    
    print('--- ToggleDoctorLock Swagger schema ---');
    final docLockPath = paths['/api/Admin/DoctorApi/ToggleDoctorLock/{doctorId}'];
    print(JsonEncoder.withIndent('  ').convert(docLockPath));

    print('\n--- TogglePatientLock Swagger schema ---');
    final patLockPath = paths['/api/Admin/PatientApi/TogglePatientLock/{id}'];
    print(JsonEncoder.withIndent('  ').convert(patLockPath));

  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
