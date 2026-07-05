import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient()..badCertificateCallback = (_, __, ___) => true;

  Future<List<Cookie>> login() async {
    final req = await client.postUrl(
      Uri.parse('http://clinicbook.runasp.net/api/Identity/AccountApi/Login'),
    );
    req.headers.set('content-type', 'application/json');
    req.add(utf8.encode(jsonEncode({'email': 'abdo85@gmail.com', 'password': '01008765502Abdo@'})));
    final res = await req.close();
    await res.drain();
    return res.cookies;
  }

  try {
    final cookies = await login();
    final choose = await client.getUrl(
      Uri.parse('http://clinicbook.runasp.net/api/Identity/AccountApi/ChooseRole?role=Doctor'),
    );
    choose.cookies.addAll(cookies);
    await (await choose.close()).drain();

    final req = await client.getUrl(
      Uri.parse('http://clinicbook.runasp.net/api/Doctor/ClinicApi/GetAllClinics?currentPage=1'),
    );
    req.cookies.addAll(cookies);
    req.headers.set('Accept', 'application/json');
    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();
    print('=== GetAllClinics (${res.statusCode}) ===');
    print(body);
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
