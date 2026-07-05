import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  dio.options.validateStatus = (status) => true;

  Future<List<Cookie>> login() async {
    final response = await dio.post(
      'http://clinicbook.runasp.net/api/Identity/AccountApi/Login',
      data: {'email': 'abdo85@gmail.com', 'password': '01008765502Abdo@'},
    );
    final cookiesHeader = response.headers['set-cookie'];
    final cookies = <Cookie>[];
    if (cookiesHeader != null) {
      for (final header in cookiesHeader) {
        cookies.add(Cookie.fromSetCookieValue(header));
      }
    }
    return cookies;
  }

  try {
    final cookies = await login();
    final cookieString = cookies.map((c) => '${c.name}=${c.value}').join('; ');
    dio.options.headers['Cookie'] = cookieString;

    // Choose role
    await dio.get('http://clinicbook.runasp.net/api/Identity/AccountApi/ChooseRole?role=Doctor');

    // Simulate ClinicModel.toJson()
    final Map<String, dynamic> clinicMap = {
      'Name': 'sui edited via dio',
      'Address': 'ss edited via dio',
      'PhoneNumber': '01008765502',
      'ConsultationPrice': 330,
      'AppointmentDuration': '30 mins',
      'Nots': '',
    };

    final formData = FormData.fromMap({'Id': 2, ...clinicMap});

    final response = await dio.put(
      'http://clinicbook.runasp.net/api/Doctor/ClinicApi/EditClinic/2',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );

    print('Status Code: ${response.statusCode}');
    print('Response Data: ${response.data}');

  } catch (e) {
    print('Error: $e');
  }
}
