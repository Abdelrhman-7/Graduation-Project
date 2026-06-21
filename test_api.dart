import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient()
    ..badCertificateCallback = (cert, host, port) => true;

  try {
    print('1. Logging in as doctor...');
    final loginUri = Uri.parse('http://medicalsystem111.runasp.net/api/Identity/AccountApi/Login');
    final loginRequest = await client.postUrl(loginUri);
    loginRequest.headers.set('content-type', 'application/json');
    loginRequest.add(utf8.encode(jsonEncode({
      'email': 'abdo85@gmail.com',
      'password': 'Abdo88@#\$gmail.com',
    })));
    
    final loginResponse = await loginRequest.close();
    final loginBody = await loginResponse.transform(utf8.decoder).join();
    print('Login Status: ${loginResponse.statusCode}');
    print('Login Response: $loginBody');

    // Extract cookies
    final cookies = loginResponse.cookies;
    print('Login Cookies: $cookies');

    if (loginResponse.statusCode != 200) {
      print('Login failed!');
      return;
    }

    print('\n2. Fetching doctor profile...');
    final profileUri = Uri.parse('http://medicalsystem111.runasp.net/api/Doctor/ProfileApi/GetProfile');
    final profileRequest = await client.getUrl(profileUri);
    // Add cookies to requests
    profileRequest.cookies.addAll(cookies);
    
    final profileResponse = await profileRequest.close();
    final profileBody = await profileResponse.transform(utf8.decoder).join();
    print('Profile Status: ${profileResponse.statusCode}');
    print('Profile Response: $profileBody');

    if (profileResponse.statusCode != 200) {
      print('Failed to get profile!');
      return;
    }

    final profileData = jsonDecode(profileBody);

    print('\n3. Testing EditProfile...');
    print('Profile data keys and values:');
    profileData.forEach((k, v) {
      print('  $k: $v (${v.runtimeType})');
    });

  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
