import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient()..badCertificateCallback = (_, __, ___) => true;

  final paths = [
    'Doctor/AppointmentApi/GetPendingBookings',
    'Doctor/AppointmentApi/GetAllBookings',
    'Doctor/BookingApi/GetPendingBookings',
    'Doctor/ScheduleApi/GetBookings',
    'Doctor/ScheduleApi/GetPendingAppointments',
    'Doctor/ClinicApi/GetBookings',
    'Doctor/ClinicApi/GetClinicBookings/4',
    'Patient/BookingApi/GetMyBookings',
    'Patient/BookingApi/GetMyAppointments',
  ];

  for (final p in paths) {
    final req = await client.getUrl(Uri.parse('http://clinicbook.runasp.net/api/$p'));
    req.headers.set('Accept', 'application/json');
    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();
    print('$p => ${res.statusCode} ${body.isEmpty ? "(empty)" : body.substring(0, body.length.clamp(0,80))}');
  }
  client.close();
}
