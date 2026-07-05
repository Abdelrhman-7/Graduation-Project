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
  final loginBody = await loginRes.transform(utf8.decoder).join();
  print('Login: ${loginRes.statusCode} $loginBody');
  print('Cookies: ${loginRes.cookies}');

  final doctorsReq = await client.getUrl(
    Uri.parse(
      'http://clinicbook.runasp.net/api/Patient/BookingApi/GetAllDoctors?currentPage=1',
    ),
  );
  doctorsReq.cookies.addAll(loginRes.cookies);
  doctorsReq.headers.set('Accept', 'application/json');
  final doctorsRes = await doctorsReq.close();
  final doctorsBody = await doctorsRes.transform(utf8.decoder).join();
  print('\nDoctors: ${doctorsRes.statusCode}');
  print(doctorsBody.length > 2000 ? doctorsBody.substring(0, 2000) : doctorsBody);

  client.close();
}
