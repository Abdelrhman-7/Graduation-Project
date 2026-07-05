import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient()
    ..badCertificateCallback = (cert, host, port) => true;

  final loginUri = Uri.parse('http://clinicbook.runasp.net/api/Identity/AccountApi/Login');
  final req = await client.postUrl(loginUri);
  req.headers.set('content-type', 'application/json');
  req.add(utf8.encode(jsonEncode({
    'email': 'admin@gmail.com',
    'password': 'Abdo88@#\$gmail.com',
  })));
  final res = await req.close();
  final body = await res.transform(utf8.decoder).join();
  print('Login: ${res.statusCode} $body');
  final token = jsonDecode(body)['token'];
  if (token == null) return;

  final paths = [
    'Patient/BookingApi/GetAllDoctors?currentPage=1',
    'Doctor/ScheduleApi/GetAllSchedules?currentPage=1',
    'Doctor/BookingApi/GetPendingBookings?currentPage=1',
    'Doctor/BookingApi/GetAllBookings?currentPage=1',
  ];

  for (final p in paths) {
    final uri = Uri.parse('http://clinicbook.runasp.net/api/$p');
    final r = await client.getUrl(uri);
    r.headers.set('Authorization', 'Bearer $token');
    r.headers.set('Accept', 'application/json');
    final resp = await r.close();
    final data = await resp.transform(utf8.decoder).join();
    print('\nGET $p => ${resp.statusCode}');
    print(data.length > 600 ? data.substring(0, 600) : data);
  }
  client.close();
}
