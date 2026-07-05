import 'dart:convert';
import 'dart:io';

Future<void> probe(String path, {String method = 'GET', Map<String, dynamic>? body}) async {
  final client = HttpClient()
    ..badCertificateCallback = (cert, host, port) => true;
  try {
    final uri = Uri.parse('http://clinicbook.runasp.net/api/$path');
    late HttpClientRequest req;
    if (method == 'GET') {
      req = await client.getUrl(uri);
    } else {
      req = await client.postUrl(uri);
      req.headers.contentType = ContentType.json;
      if (body != null) req.write(jsonEncode(body));
    }
    req.headers.set('Accept', 'application/json');
    final res = await req.close();
    final data = await res.transform(utf8.decoder).join();
    print('$method $path => ${res.statusCode}');
    if (data.isNotEmpty && data.length < 500) print('  $data');
    if (data.length >= 500) print('  ${data.substring(0, 500)}...');
  } catch (e) {
    print('$method $path => ERROR: $e');
  } finally {
    client.close();
  }
}

void main() async {
  final paths = [
    'Doctor/BookingApi/GetPendingBookings',
    'Doctor/BookingApi/GetAllBookings',
    'Doctor/BookingApi/GetBookings',
    'Doctor/ScheduleApi/GetClinicBookings?clinicId=1',
    'Doctor/ScheduleApi/GetPendingAppointments',
    'Doctor/AppointmentApi/GetPendingBookings',
    'Doctor/NotificationApi/GetNotifications',
    'Patient/BookingApi/GetMyBookings',
    'Patient/BookingApi/GetMyAppointments',
  ];
  for (final p in paths) {
    await probe(p);
  }
}
