import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient()
    ..badCertificateCallback = (cert, host, port) => true;

  final loginReq = await client.postUrl(
    Uri.parse('http://clinicbook.runasp.net/api/Identity/AccountApi/Login'),
  );
  loginReq.headers.set('content-type', 'application/json');
  loginReq.add(utf8.encode(jsonEncode({
    'email': 'wwwabdo77@gmail.com',
    'password': '01008765502Abdo@',
  })));
  final loginRes = await loginReq.close();
  await loginRes.drain();
  final cookies = loginRes.cookies;

  for (final doctorId in [1, 2]) {
    final clinicsReq = await client.getUrl(
      Uri.parse('http://clinicbook.runasp.net/api/Patient/BookingApi/GetDoctorClinics/$doctorId?currentPage=1'),
    );
    clinicsReq.cookies.addAll(cookies);
    final clinicsRes = await clinicsReq.close();
    final clinicsBody = await clinicsRes.transform(utf8.decoder).join();
    print('Doctor $doctorId clinics: ${clinicsRes.statusCode}');
    print(clinicsBody);
    print('');

    final json = jsonDecode(clinicsBody) as Map<String, dynamic>;
    final clinics = json['clinics'] as List? ?? [];
    for (final c in clinics) {
      final clinicId = c['clinicId'] ?? c['id'] ?? c['Id'];
      final schedReq = await client.getUrl(
        Uri.parse('http://clinicbook.runasp.net/api/Patient/BookingApi/GetClinicSchedules/$clinicId?currentPage=1'),
      );
      schedReq.cookies.addAll(cookies);
      final schedRes = await schedReq.close();
      final schedBody = await schedRes.transform(utf8.decoder).join();
      print('Clinic $clinicId schedules: ${schedRes.statusCode}');
      print(schedBody);
      print('');
    }
  }

  client.close();
}
