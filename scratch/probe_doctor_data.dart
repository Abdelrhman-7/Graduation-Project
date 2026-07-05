import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient()..badCertificateCallback = (_, __, ___) => true;

  Future<List<Cookie>> login(String email, String password) async {
    final req = await client.postUrl(
      Uri.parse('http://clinicbook.runasp.net/api/Identity/AccountApi/Login'),
    );
    req.headers.set('content-type', 'application/json');
    req.add(utf8.encode(jsonEncode({'email': email, 'password': password})));
    final res = await req.close();
    await res.drain();
    return res.cookies;
  }

  Future<void> probe(String path, List<Cookie> cookies, {String method = 'GET', Map? body}) async {
    final uri = Uri.parse('http://clinicbook.runasp.net/api/$path');
    final req = method == 'GET'
        ? await client.getUrl(uri)
        : await client.postUrl(uri);
    req.cookies.addAll(cookies);
    if (body != null) {
      req.headers.set('content-type', 'application/json');
      req.add(utf8.encode(jsonEncode(body)));
    }
    final res = await req.close().timeout(const Duration(seconds: 30));
    final data = await res.transform(utf8.decoder).join();
    print('\n=== $method $path => ${res.statusCode} ===');
    print(data.length > 2000 ? '${data.substring(0, 2000)}...' : data);
  }

  final d = await login('abdo85@gmail.com', '01008765502Abdo@');
  await probe('Identity/AccountApi/ChooseRole?role=Doctor', d);
  await probe('Doctor/ScheduleApi/GetAllSchedules?currentPage=1', d);
  await probe('Doctor/ScheduleApi/GetSchedule/4', d);
  await probe('Doctor/ClinicApi/GetAllClinics?currentPage=1', d);
  await probe('Doctor/ClinicApi/GetClinic/4', d);

  // wider probe
  for (final p in [
    'Doctor/BookingApi/GetPendingBookings?currentPage=1',
    'Doctor/AppointmentApi/GetPendingBookings?currentPage=1',
    'Doctor/NotificationApi/GetAll?currentPage=1',
    'Doctor/NotificationsApi/GetAll?currentPage=1',
    'NotificationApi/GetDoctorNotifications?currentPage=1',
  ]) {
    await probe(p, d);
  }

  client.close();
}
