import 'dart:convert';
import 'dart:io';

Future<void> testLogin(String email, String password, String label) async {
  final client = HttpClient()
    ..badCertificateCallback = (cert, host, port) => true;

  final loginReq = await client.postUrl(
    Uri.parse('http://clinicbook.runasp.net/api/Identity/AccountApi/Login'),
  );
  loginReq.headers.set('content-type', 'application/json');
  loginReq.add(utf8.encode(jsonEncode({'email': email, 'password': password})));
  final loginRes = await loginReq.close();
  final loginBody = await loginRes.transform(utf8.decoder).join();
  print('$label login: ${loginRes.statusCode} $loginBody');

  final doctorsReq = await client.getUrl(
    Uri.parse('http://clinicbook.runasp.net/api/Patient/BookingApi/GetAllDoctors?currentPage=1'),
  );
  doctorsReq.cookies.addAll(loginRes.cookies);
  final doctorsRes = await doctorsReq.close();
  final doctorsBody = await doctorsRes.transform(utf8.decoder).join();
  print('$label doctors: ${doctorsRes.statusCode} $doctorsBody\n');
  client.close();
}

void main() async {
  await testLogin('wwwabdo77@gmail.com', '01008765502Abdo@', 'Patient');
}
