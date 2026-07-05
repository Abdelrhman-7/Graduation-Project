import 'dart:convert';
import 'dart:io';

Future<Map<String, dynamic>> login(String email, String password) async {
  final client = HttpClient()
    ..badCertificateCallback = (cert, host, port) => true;
  final loginUri = Uri.parse('http://clinicbook.runasp.net/api/Identity/AccountApi/Login');
  final req = await client.postUrl(loginUri);
  req.headers.set('content-type', 'application/json');
  req.add(utf8.encode(jsonEncode({'email': email, 'password': password})));
  final res = await req.close();
  final body = await res.transform(utf8.decoder).join();
  client.close();
  final data = jsonDecode(body);
  return {
    'status': res.statusCode,
    'token': data['token'],
    'role': data['role'] ?? data['Role'],
    'body': body,
  };
}

Future<void> get(String path, String token) async {
  final client = HttpClient()
    ..badCertificateCallback = (cert, host, port) => true;
  final uri = Uri.parse('http://clinicbook.runasp.net/api/$path');
  final req = await client.getUrl(uri);
  req.headers.set('Authorization', 'Bearer $token');
  req.headers.set('Accept', 'application/json');
  final res = await req.close();
  final body = await res.transform(utf8.decoder).join();
  client.close();
  print('GET $path => ${res.statusCode}');
  print(body.length > 800 ? '${body.substring(0, 800)}...' : body);
  print('');
}

Future<void> postJson(String path, String token, Map<String, dynamic> data) async {
  final client = HttpClient()
    ..badCertificateCallback = (cert, host, port) => true;
  final uri = Uri.parse('http://clinicbook.runasp.net/api/$path');
  final req = await client.postUrl(uri);
  req.headers.set('Authorization', 'Bearer $token');
  req.headers.set('content-type', 'application/json');
  req.add(utf8.encode(jsonEncode(data)));
  final res = await req.close();
  final body = await res.transform(utf8.decoder).join();
  client.close();
  print('POST $path => ${res.statusCode}');
  print(body);
  print('');
}

void main() async {
  print('=== Patient login ===');
  final patient = await login('wwwabdo77@gmail.com', '01008765502Abdo@');
  print('Status: ${patient['status']}, role: ${patient['role']}');
  final pToken = patient['token'];
  if (pToken == null) {
    print('Patient login failed: ${patient['body']}');
    return;
  }

  await get('Patient/BookingApi/GetAllDoctors?currentPage=1', pToken);
  await get('Patient/BookingApi/GetDoctor/1', pToken);
  await get('Patient/BookingApi/GetDoctorClinics/1?currentPage=1', pToken);
  await get('Patient/BookingApi/GetClinicSchedules/1?currentPage=1', pToken);

  print('=== Doctor login ===');
  final doctor = await login('abdo85@gmail.com', r'Abdo88@#$gmail.com');
  print('Status: ${doctor['status']}, role: ${doctor['role']}');
  final dToken = doctor['token'];
  if (dToken != null) {
    await get('Doctor/ScheduleApi/GetAllSchedules?currentPage=1', dToken);
    for (final p in [
      'Doctor/BookingApi/GetPendingBookings',
      'Doctor/BookingApi/GetAllBookings',
      'Doctor/BookingApi/AcceptBooking/1',
      'Doctor/BookingApi/RejectBooking/1',
    ]) {
      await get(p, dToken);
    }
  }
}
