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

    print('\n2. Fetching clinics for doctor ID 2...');
    final clinicsUri = Uri.parse('http://medicalsystem111.runasp.net/api/Patient/PatientDoctorApi/GetDoctorClinics?doctorId=2');
    final clinicsRequest = await client.getUrl(clinicsUri);
    clinicsRequest.cookies.addAll(cookies);
    if (token != null) {
      clinicsRequest.headers.set('Authorization', 'Bearer $token');
    }
    
    final clinicsResponse = await clinicsRequest.close();
    final clinicsBody = await clinicsResponse.transform(utf8.decoder).join();
    print('Clinics Status: ${clinicsResponse.statusCode}');
    print('Clinics Response: $clinicsBody');

  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
