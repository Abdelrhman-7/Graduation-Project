import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient()
    ..badCertificateCallback = (cert, host, port) => true;

  Future<HttpClientResponse> post(String path, {Map? body, List<Cookie>? cookies}) async {
    final req = await client.postUrl(Uri.parse('http://clinicbook.runasp.net/api/$path'));
    if (cookies != null) req.cookies.addAll(cookies);
    if (body != null) {
      req.headers.set('content-type', 'application/json');
      req.add(utf8.encode(jsonEncode(body)));
    }
    return req.close();
  }

  Future<HttpClientResponse> get(String path, {List<Cookie>? cookies}) async {
    final req = await client.getUrl(Uri.parse('http://clinicbook.runasp.net/api/$path'));
    if (cookies != null) req.cookies.addAll(cookies);
    req.headers.set('Accept', 'application/json');
    return req.close();
  }

  final loginRes = await post('Identity/AccountApi/Login', body: {
    'email': 'wwwabdo77@gmail.com',
    'password': '01008765502Abdo@',
  });
  final loginBody = await loginRes.transform(utf8.decoder).join();
  print('Login: ${loginRes.statusCode} $loginBody');
  final cookies = loginRes.cookies;

  // Without chooseRole
  var res = await get('Patient/BookingApi/GetAllDoctors?currentPage=1', cookies: cookies);
  print('Doctors (no role): ${res.statusCode} ${await res.transform(utf8.decoder).join()}');

  // With chooseRole
  final roleRes = await get('Identity/AccountApi/ChooseRole?role=Patient', cookies: cookies);
  print('ChooseRole: ${roleRes.statusCode} ${await roleRes.transform(utf8.decoder).join()}');

  res = await get('Patient/BookingApi/GetAllDoctors?currentPage=1', cookies: cookies);
  print('Doctors (after role): ${res.statusCode} ${await res.transform(utf8.decoder).join()}');

  client.close();
}
