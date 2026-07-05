import 'dart:io';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

void main() async {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://clinicbook.runasp.net/api/',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    ),
  );

  final cookieJar = CookieJar();
  dio.interceptors.add(CookieManager(cookieJar));

  try {
    // 1. Login
    final loginRes = await dio.post(
      'Identity/AccountApi/Login',
      data: {'email': 'abdo85@gmail.com', 'password': '01008765502Abdo@'},
    );
    print('Login status: ${loginRes.statusCode}');

    // 2. Choose Role
    final roleRes = await dio.get('Identity/AccountApi/ChooseRole?role=Doctor');
    print('ChooseRole status: ${roleRes.statusCode}');

    // Get current schedule to see details
    final schedRes = await dio.get('Doctor/ScheduleApi/GetSchedule/4');
    print('Current schedule: ${schedRes.data}');

    // 3. Edit Schedule
    final mapData = <String, dynamic>{
      'DayOfWeek': 'Sunday',
      'StartTime': '09:00:00',
      'EndTime': '17:00:00',
      'AppointmentDuration': 30,
      'Notes': 'Test Edit Notes',
    };

    print('Sending EditSchedule data: $mapData');

    final response = await dio.put(
      'Doctor/ScheduleApi/EditSchedule/4',
      data: FormData.fromMap(mapData),
      options: Options(validateStatus: (status) => true),
    );

    print('EditSchedule Response Code: ${response.statusCode}');
    print('EditSchedule Response Body: ${response.data}');

  } catch (e) {
    print('Error: $e');
  }
}
