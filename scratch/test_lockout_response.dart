import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient()
    ..badCertificateCallback = (cert, host, port) => true;

  try {
    print('1. Logging in as Admin...');
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
    
    final loginData = jsonDecode(loginBody);
    final token = loginData['token'];
    final List<String> setCookies = loginResponse.headers['set-cookie'] ?? [];

    print('\n2. Fetching all doctors...');
    final doctorsUri = Uri.parse('http://clinicbook.runasp.net/api/Admin/DoctorApi/GetAllDoctors?currentPage=1');
    final doctorsRequest = await client.getUrl(doctorsUri);
    if (token != null) {
      doctorsRequest.headers.set('Authorization', 'Bearer $token');
    }
    for (var c in setCookies) {
      doctorsRequest.headers.add('Cookie', c);
    }
    
    final doctorsResponse = await doctorsRequest.close();
    final doctorsBody = await doctorsResponse.transform(utf8.decoder).join();
    print('Doctors Status: ${doctorsResponse.statusCode}');
    final doctors = jsonDecode(doctorsBody);
    if (doctors is List && doctors.isNotEmpty) {
      print('First Doctor keys & lockout values:');
      final firstDoctor = doctors.first;
      firstDoctor.forEach((k, v) {
        if (k.toLowerCase().contains('lock') || k.toLowerCase().contains('out') || k.toLowerCase().contains('end')) {
          print('  $k: $v (${v.runtimeType})');
        }
      });
      print('All keys: ${firstDoctor.keys.toList()}');
    } else {
      print('Doctors: $doctors');
    }

    print('\n3. Fetching all patients...');
    final patientsUri = Uri.parse('http://clinicbook.runasp.net/api/Admin/PatientApi/GetAllPatients?currentPage=1');
    final patientsRequest = await client.getUrl(patientsUri);
    if (token != null) {
      patientsRequest.headers.set('Authorization', 'Bearer $token');
    }
    for (var c in setCookies) {
      patientsRequest.headers.add('Cookie', c);
    }
    
    final patientsResponse = await patientsRequest.close();
    final patientsBody = await patientsResponse.transform(utf8.decoder).join();
    print('Patients Status: ${patientsResponse.statusCode}');
    final patients = jsonDecode(patientsBody);
    if (patients is List && patients.isNotEmpty) {
      print('First Patient keys & lockout values:');
      final firstPatient = patients.first;
      firstPatient.forEach((k, v) {
        if (k.toLowerCase().contains('lock') || k.toLowerCase().contains('out') || k.toLowerCase().contains('end')) {
          print('  $k: $v (${v.runtimeType})');
        }
      });
      print('All keys: ${firstPatient.keys.toList()}');
    } else {
      print('Patients: $patients');
    }

  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
