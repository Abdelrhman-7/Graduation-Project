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

  final cookies = await login();
  final choose = await client.getUrl(
    Uri.parse('http://clinicbook.runasp.net/api/Identity/AccountApi/ChooseRole?role=Patient'),
  );
  choose.cookies.addAll(cookies);
  await (await choose.close()).drain();

  final book = await client.postUrl(
    Uri.parse('http://clinicbook.runasp.net/api/Patient/BookingApi/BookAppointment/4'),
  );
  book.cookies.addAll(cookies);
  book.headers.set('content-type', 'application/json');
  book.add(utf8.encode(jsonEncode({
    'reasonForVisit': 'Test headache follow up visit',
    'paymentMethod': 'Pay Online',
  })));
  final bookRes = await book.close().timeout(const Duration(seconds: 45));
  final body = await bookRes.transform(utf8.decoder).join();
  print('Status: ${bookRes.statusCode}');
  print('Body: $body');
  client.close();
}
