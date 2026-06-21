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

    // Extract cookies
    final cookies = loginResponse.cookies;
    final loginData = jsonDecode(loginBody);
    final token = loginData['token'];

    print('\n2. Fetching all doctors...');
    final doctorsUri = Uri.parse('http://medicalsystem111.runasp.net/api/Patient/AppointmentApi/GetAllDoctors?currentPage=1');
    final doctorsRequest = await client.getUrl(doctorsUri);
    doctorsRequest.cookies.addAll(cookies);
    if (token != null) {
      doctorsRequest.headers.set('Authorization', 'Bearer $token');
    }
    
    final doctorsResponse = await doctorsRequest.close();
    final doctorsBody = await doctorsResponse.transform(utf8.decoder).join();
    print('Doctors Status: ${doctorsResponse.statusCode}');
    print('Doctors Response: $doctorsBody');

  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
