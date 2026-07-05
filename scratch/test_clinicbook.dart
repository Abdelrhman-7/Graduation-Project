import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient()
    ..badCertificateCallback = (cert, host, port) => true;

  try {
    print('Testing clinicbook.runasp.net with doctor password...');
    final loginUri = Uri.parse('http://clinicbook.runasp.net/api/Identity/AccountApi/Login');
    final loginRequest = await client.postUrl(loginUri);
    loginRequest.headers.set('content-type', 'application/json');
    loginRequest.add(utf8.encode(jsonEncode({
      'email': 'admin@gmail.com',
      'password': 'Abdo88@#\$gmail.com',
    })));
    
    final loginResponse = await loginRequest.close();
    final loginBody = await loginResponse.transform(utf8.decoder).join();
    print('Login Status: ${loginResponse.statusCode}');
    print('Login Response: $loginBody');
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
