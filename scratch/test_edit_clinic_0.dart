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

    // Now edit clinic 0
    final boundary = '----WebKitFormBoundary7MA4YWxkTrZu0gW';
    final editReq = await client.putUrl(
      Uri.parse('http://clinicbook.runasp.net/api/Doctor/ClinicApi/EditClinic/0'),
    );
    editReq.cookies.addAll(cookies);
    editReq.headers.set('content-type', 'multipart/form-data; boundary=$boundary');

    final buffer = StringBuffer();
    void addField(String name, String value) {
      buffer.write('--$boundary\r\n');
      buffer.write('Content-Disposition: form-data; name="$name"\r\n\r\n');
      buffer.write('$value\r\n');
    }

    addField('Id', '0');
    addField('Name', 'sui updated');
    addField('Address', 'ss updated');
    addField('PhoneNumber', '01008765502');
    addField('ConsultationPrice', '350');

    buffer.write('--$boundary--\r\n');

    final bodyBytes = utf8.encode(buffer.toString());
    editReq.headers.set('content-length', bodyBytes.length.toString());
    editReq.add(bodyBytes);

    final editRes = await editReq.close();
    final body = await editRes.transform(utf8.decoder).join();
    print('Edit Status: ${editRes.statusCode}');
    print('Response body: $body');

  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
