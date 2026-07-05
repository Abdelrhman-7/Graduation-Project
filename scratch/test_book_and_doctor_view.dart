import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient()..badCertificateCallback = (_, __, ___) => true;

  Future<List<Cookie>> login(String email, String password) async {
    final req = await client.postUrl(
      Uri.parse('http://clinicbook.runasp.net/api/Identity/AccountApi/Login'),
    );
    req.headers.set('content-type', 'application/json');
    req.add(utf8.encode(jsonEncode({'email': email, 'password': password})));
    final res = await req.close();
    await res.drain();
    return res.cookies;
  }

  Future<String> get(String path, List<Cookie> cookies) async {
    final req = await client.getUrl(Uri.parse('http://clinicbook.runasp.net/api/$path'));
    req.cookies.addAll(cookies);
    final res = await req.close();
    return res.transform(utf8.decoder).join();
  }

  Future<String> post(String path, List<Cookie> cookies, Map body) async {
    final req = await client.postUrl(Uri.parse('http://clinicbook.runasp.net/api/$path'));
    req.cookies.addAll(cookies);
    req.headers.set('content-type', 'application/json');
    req.add(utf8.encode(jsonEncode(body)));
    final res = await req.close();
    return res.transform(utf8.decoder).join();
  }

  final p = await login('wwwabdo77@gmail.com', '01008765502Abdo@');
  await get('Identity/AccountApi/ChooseRole?role=Patient', p);
  print('Book: ${await post('Patient/BookingApi/BookAppointment/4', p, {
    'reasonForVisit': 'Test booking from script headache',
    'paymentMethod': 'Pay Online',
  })}');

  final d = await login('abdo85@gmail.com', '01008765502Abdo@');
  await get('Identity/AccountApi/ChooseRole?role=Doctor', d);
  print('\nDoctor schedules:\n${await get('Doctor/ScheduleApi/GetAllSchedules?currentPage=1', d)}');
  print('\nDoctor clinics:\n${await get('Doctor/ClinicApi/GetAllClinics?currentPage=1', d)}');

  client.close();
}
