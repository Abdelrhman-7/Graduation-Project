import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient()..badCertificateCallback = (_, __, ___) => true;

  Future<List<Cookie>> login() async {
    final req = await client.postUrl(
      Uri.parse('http://clinicbook.runasp.net/api/Identity/AccountApi/Login'),
    );
    req.headers.set('content-type', 'application/json');
    req.add(utf8.encode(jsonEncode({'email': 'wwwabdo77@gmail.com', 'password': '01008765502Abdo@'})));
    final res = await req.close();
    await res.drain();
    return res.cookies;
  }

  try {
    final cookies = await login();
    final choose = await client.getUrl(
      Uri.parse('http://clinicbook.runasp.net/api/Identity/AccountApi/ChooseRole?role=Patient'),
    );
    choose.cookies.addAll(cookies);
    await (await choose.close()).drain();

    final urls = [
      'Patient/BookingApi/GetDoctorClinics/2',
      'Patient/BookingApi/GetDoctorClinics/1',
      'Patient/BookingApi/GetClinicSchedules/2',
      'Patient/BookingApi/GetClinicSchedules/1',
    ];

    for (final url in urls) {
      final req = await client.getUrl(
        Uri.parse('http://clinicbook.runasp.net/api/$url'),
      );
      req.cookies.addAll(cookies);
      req.headers.set('Accept', 'application/json');
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      print('=== GET $url (${res.statusCode}) ===');
      if (body.isNotEmpty) {
        try {
          final decoded = jsonDecode(body);
          print(JsonEncoder.withIndent('  ').convert(decoded));
        } catch (_) {
          print(body);
        }
      } else {
        print('(empty)');
      }
      print('');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
