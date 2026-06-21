import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient()
    ..badCertificateCallback = (cert, host, port) => true;

  try {
    print('1. Logging in as patient...');
    final loginUri = Uri.parse('http://medicalsystem111.runasp.net/api/Identity/AccountApi/Login');
    final loginRequest = await client.postUrl(loginUri);
    loginRequest.headers.set('content-type', 'application/json');
    loginRequest.add(utf8.encode(jsonEncode({
      'email': 'wwwabdo77@gmail.com',
      'password': '01008765502Abdo@',
    })));
    
    final loginResponse = await loginRequest.close();
    final loginBody = await loginResponse.transform(utf8.decoder).join();
    print('Login Status: ${loginResponse.statusCode}');
    print('Login Response: $loginBody');

    // Extract cookies and token
    final cookies = loginResponse.cookies;
    final loginData = jsonDecode(loginBody);
    final token = loginData['token'];

    if (token == null) {
      print('Login failed, token is null');
      return;
    }

    print('\n2. Fetching schedules for doctor 1, clinic 1...');
    final schedUri = Uri.parse('http://medicalsystem111.runasp.net/api/Patient/AppointmentApi/GetClinicSchedules?doctorId=1&clinicId=1');
    final schedRequest = await client.getUrl(schedUri);
    schedRequest.cookies.addAll(cookies);
    schedRequest.headers.set('Authorization', 'Bearer $token');
    
    final schedResponse = await schedRequest.close();
    final schedBody = await schedResponse.transform(utf8.decoder).join();
    print('Schedules Status: ${schedResponse.statusCode}');
    print('Schedules Response: $schedBody');

    final schedules = jsonDecode(schedBody);
    int scheduleId = 0;
    if (schedules is List && schedules.isNotEmpty) {
      scheduleId = schedules[0]['id'];
    } else if (schedules is Map && schedules.containsKey('schedules') && schedules['schedules'].isNotEmpty) {
      scheduleId = schedules['schedules'][0]['id'];
    }

    if (scheduleId == 0) {
      print('No schedules found, using fallback ID 2');
      scheduleId = 2;
    }

    print('\n3. Booking appointment with Schedule ID: $scheduleId...');
    final bookUri = Uri.parse('http://medicalsystem111.runasp.net/api/Patient/AppointmentApi/BookAppointment');
    
    // Using multipart/form-data
    final boundary = '----DartBoundary${DateTime.now().millisecondsSinceEpoch}';
    final bookRequest = await client.postUrl(bookUri);
    bookRequest.cookies.addAll(cookies);
    bookRequest.headers.set('Authorization', 'Bearer $token');
    bookRequest.headers.set('content-type', 'multipart/form-data; boundary=$boundary');

    final buffer = StringBuffer();
    
    // ScheduleId
    buffer.write('--$boundary\r\n');
    buffer.write('content-disposition: form-data; name="ScheduleId"\r\n\r\n');
    buffer.write('$scheduleId\r\n');

    // ReasonForVisit
    buffer.write('--$boundary\r\n');
    buffer.write('content-disposition: form-data; name="ReasonForVisit"\r\n\r\n');
    buffer.write('Headache and follow-up check\r\n');

    // PaymentMethod
    buffer.write('--$boundary\r\n');
    buffer.write('content-disposition: form-data; name="PaymentMethod"\r\n\r\n');
    buffer.write('Pay Online\r\n');

    buffer.write('--$boundary--\r\n');

    bookRequest.add(utf8.encode(buffer.toString()));

    final stopwatch = Stopwatch()..start();
    final bookResponse = await bookRequest.close();
    final bookBody = await bookResponse.transform(utf8.decoder).join();
    stopwatch.stop();

    print('Book Appointment Status: ${bookResponse.statusCode}');
    print('Time Taken: ${stopwatch.elapsedMilliseconds} ms');
    print('Book Appointment Response: $bookBody');

  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
