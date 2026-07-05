import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient()..badCertificateCallback = (_, __, ___) => true;
  final req = await client.postUrl(
    Uri.parse('http://clinicbook.runasp.net/api/Identity/AccountApi/Login'),
  );
  req.headers.set('content-type', 'application/json');
  req.add(utf8.encode(jsonEncode({'email': 'abdo85@gmail.com', 'password': '01008765502Abdo@'})));
  final res = await req.close();
  final cookies = res.cookies;
  await res.drain();

  final roleReq = await client.getUrl(
    Uri.parse('http://clinicbook.runasp.net/api/Identity/AccountApi/ChooseRole?role=Doctor'),
  );
  roleReq.cookies.addAll(cookies);
  await (await roleReq.close()).drain();

  final profReq = await client.getUrl(
    Uri.parse('http://clinicbook.runasp.net/api/Doctor/ProfileApi/GetProfile'),
  );
  profReq.cookies.addAll(cookies);
  final profRes = await profReq.close();
  print(await profRes.transform(utf8.decoder).join());
  client.close();
}
