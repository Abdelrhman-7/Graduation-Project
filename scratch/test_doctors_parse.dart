import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient()
    ..badCertificateCallback = (cert, host, port) => true;

  // Without cookies
  final req1 = await client.getUrl(
    Uri.parse('http://clinicbook.runasp.net/api/Patient/BookingApi/GetAllDoctors?currentPage=1'),
  );
  req1.headers.set('Accept', 'application/json');
  final res1 = await req1.close();
  final body1 = await res1.transform(utf8.decoder).join();
  print('Without cookies: ${res1.statusCode}');
  print('Body length: ${body1.length}');
  print(body1.isEmpty ? '(empty)' : body1.substring(0, body1.length.clamp(0, 200)));
  print('');

  // With cookies
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

  final req2 = await client.getUrl(
    Uri.parse('http://clinicbook.runasp.net/api/Patient/BookingApi/GetAllDoctors?currentPage=1'),
  );
  req2.cookies.addAll(loginRes.cookies);
  req2.headers.set('Accept', 'application/json');
  final res2 = await req2.close();
  final body2 = await res2.transform(utf8.decoder).join();
  print('With cookies: ${res2.statusCode}');
  print(body2);

  // Parse test
  final json = jsonDecode(body2);
  final doctors = json['doctors'] as List;
  for (final d in doctors) {
    final id = d['doctorId'] ?? d['id'];
    print('Doctor: $id - ${d['fullName']}');
  }

  client.close();
}
