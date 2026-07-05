import 'dart:convert';
import 'dart:io';

Future<void> testFields(Map<String, String> fields) async {
  final client = HttpClient()..badCertificateCallback = (_, __, ___) => true;
  
  // 1. Login
  final loginReq = await client.postUrl(
    Uri.parse('http://clinicbook.runasp.net/api/Identity/AccountApi/Login'),
  );
  loginReq.headers.set('content-type', 'application/json');
  loginReq.add(utf8.encode(jsonEncode({
    'email': 'wwwabdo77@gmail.com',
    'password': '01008765502Abdo@',
  })));
  final loginRes = await loginReq.close();
  final loginString = await loginRes.transform(utf8.decoder).join();
  final cookies = loginRes.cookies;
  
  // 2. Choose Role
  final roleReq = await client.getUrl(
    Uri.parse('http://clinicbook.runasp.net/api/Identity/AccountApi/ChooseRole?role=Patient'),
  );
  roleReq.cookies.addAll(cookies);
  final roleRes = await roleReq.close();
  await roleRes.drain();

  // 3. Edit Profile
  final editReq = await client.putUrl(
    Uri.parse('http://clinicbook.runasp.net/api/Patient/ProfileApi/EditProfile'),
  );
  editReq.cookies.addAll(cookies);
  
  final boundary = '------Boundary${DateTime.now().millisecondsSinceEpoch}';
  editReq.headers.set('content-type', 'multipart/form-data; boundary=$boundary');
  
  final buffer = StringBuffer();
  fields.forEach((key, value) {
    buffer.write('--$boundary\r\n');
    buffer.write('Content-Disposition: form-data; name="$key"\r\n\r\n');
    buffer.write('$value\r\n');
  });
  buffer.write('--$boundary--\r\n');
  
  editReq.add(utf8.encode(buffer.toString()));
  
  final editRes = await editReq.close();
  print('Fields: $fields');
  print('Response code: ${editRes.statusCode}');
  final editString = await editRes.transform(utf8.decoder).join();
  print('Response body: $editString\n');
  
  client.close();
}

void main() async {
  // Test 1: Empty FullName
  await testFields({
    'FullName': '',
    'PhoneNumber': '01008765502',
    'Address': 'Cairo', 
    'Gender': 'male',
    'DateOfBirth': '01/01/2004', 
  });

  // Test 2: Empty PhoneNumber
  await testFields({
    'FullName': 'Abdo',
    'PhoneNumber': '',
    'Address': 'Cairo', 
    'Gender': 'male',
    'DateOfBirth': '01/01/2004', 
  });

  // Test 3: Empty Gender
  await testFields({
    'FullName': 'Abdo',
    'PhoneNumber': '01008765502',
    'Address': 'Cairo', 
    'Gender': '',
    'DateOfBirth': '01/01/2004', 
  });

  // Test 4: Empty DateOfBirth
  await testFields({
    'FullName': 'Abdo',
    'PhoneNumber': '01008765502',
    'Address': 'Cairo', 
    'Gender': 'male',
    'DateOfBirth': '', 
  });
}
