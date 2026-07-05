import 'dart:convert';
import 'dart:io';

Future<List<Cookie>> login(HttpClient client, String email, String password) async {
  final req = await client.postUrl(
    Uri.parse('http://clinicbook.runasp.net/api/Identity/AccountApi/Login'),
  );
  req.headers.set('content-type', 'application/json');
  req.add(utf8.encode(jsonEncode({'email': email, 'password': password})));
  final res = await req.close();
  await res.drain();
  return res.cookies;
}

Future<void> get(HttpClient client, String path, List<Cookie> cookies) async {
  final req = await client.getUrl(Uri.parse('http://clinicbook.runasp.net/api/$path'));
  req.cookies.addAll(cookies);
  req.headers.set('Accept', 'application/json');
  final res = await req.close();
  final body = await res.transform(utf8.decoder).join();
  print('GET $path => ${res.statusCode}');
  print(body.length > 600 ? body.substring(0, 600) : body);
  print('');
}

Future<void> postJson(HttpClient client, String path, List<Cookie> cookies, Map body) async {
  final req = await client.postUrl(Uri.parse('http://clinicbook.runasp.net/api/$path'));
  req.cookies.addAll(cookies);
  req.headers.set('content-type', 'application/json');
  req.add(utf8.encode(jsonEncode(body)));
  final res = await req.close();
  final data = await res.transform(utf8.decoder).join();
  print('POST $path => ${res.statusCode}');
  print(data);
  print('');
}

void main() async {
  final client = HttpClient()..badCertificateCallback = (_, __, ___) => true;

  print('=== PATIENT: book appointment ===');
  final pCookies = await login(client, 'wwwabdo77@gmail.com', '01008765502Abdo@');
  await get(client, 'Identity/AccountApi/ChooseRole?role=Patient', pCookies);
  await postJson(client, 'Patient/BookingApi/BookAppointment/4', pCookies, {
    'reasonForVisit': 'Headache and follow-up check test',
    'paymentMethod': 'Pay Online',
  });

  print('=== DOCTOR: probe booking endpoints ===');
  final dCookies = await login(client, 'abdo85@gmail.com', '01008765502Abdo@');
  await get(client, 'Identity/AccountApi/ChooseRole?role=Doctor', dCookies);

  final paths = [
    'Doctor/BookingApi/GetPendingBookings?currentPage=1',
    'Doctor/BookingApi/GetAllBookings?currentPage=1',
    'Doctor/ScheduleApi/GetAllSchedules?currentPage=1',
    'Doctor/ClinicApi/GetAllClinics?currentPage=1',
    'Patient/BookingApi/GetMyBookings?currentPage=1',
  ];
  for (final p in paths) {
    await get(client, p, dCookies);
  }

  client.close();
}
