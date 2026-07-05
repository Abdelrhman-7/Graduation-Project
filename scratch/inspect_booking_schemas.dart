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
    final paths = json['paths'] as Map<String, dynamic>;

    final targets = [
      '/api/Patient/BookingApi/BookAppointment/{scheduleId}',
      '/api/Patient/BookingApi/GetClinicSchedules/{clinicId}',
      '/api/Patient/BookingApi/GetAllDoctors',
      '/api/Patient/BookingApi/AppointmentSummary/{scheduleId}',
    ];

    for (final t in targets) {
      print('\n=== $t ===');
      print(JsonEncoder.withIndent('  ').convert(paths[t]));
    }

    print('\n=== Schemas ===');
    final schemas = json['components']['schemas'] as Map<String, dynamic>;
    for (final key in schemas.keys) {
      if (key.toLowerCase().contains('book') ||
          key.toLowerCase().contains('appoint') ||
          key.toLowerCase().contains('schedule') ||
          key.toLowerCase().contains('doctor')) {
        print('\n--- $key ---');
        print(JsonEncoder.withIndent('  ').convert(schemas[key]));
      }
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
