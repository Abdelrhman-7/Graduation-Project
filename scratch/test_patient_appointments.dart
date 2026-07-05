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

  try {
    final cookies = await login();
    final choose = await client.getUrl(
      Uri.parse('http://clinicbook.runasp.net/api/Identity/AccountApi/ChooseRole?role=Patient'),
    );
    choose.cookies.addAll(cookies);
    await (await choose.close()).drain();

    final req = await client.getUrl(
      Uri.parse('http://clinicbook.runasp.net/api/Patient/AppointmentApi/GetAllAppointments?currentPage=1'),
    );
    req.cookies.addAll(cookies);
    req.headers.set('Accept', 'application/json');
    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();
    
    print('=== GetAllAppointments (${res.statusCode}) ===');
    if (res.statusCode == 200 || res.statusCode == 201) {
      final decoded = jsonDecode(body);
      print(JsonEncoder.withIndent('  ').convert(decoded));
      
      if (decoded is Map && decoded['appointments'] != null && decoded['appointments'] is List) {
          final list = decoded['appointments'];
          if (list.isNotEmpty) {
              final first = list.first;
              final id = first['id'] ?? first['appointmentId'] ?? first['bookingId'];
              print('First item ID: $id');
              if (id != null) {
                  final getReq = await client.getUrl(
                      Uri.parse('http://clinicbook.runasp.net/api/Patient/AppointmentApi/GetAppointment/$id'),
                  );
                  getReq.cookies.addAll(cookies);
                  getReq.headers.set('Accept', 'application/json');
                  final getRes = await getReq.close();
                  final getBody = await getRes.transform(utf8.decoder).join();
                  print('=== GetAppointment/$id (${getRes.statusCode}) ===');
                  print(getBody);
              }
          }
      }
    } else {
      print(body);
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
