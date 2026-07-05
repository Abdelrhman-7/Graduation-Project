import 'package:graduationproject/data/api/api_manager.dart';
import 'package:graduationproject/data/models/Auth/login_model.dart';
import 'package:flutter/widgets.dart';

void main() async {
  // We need to initialize WidgetsFlutterBinding because ApiManager uses getApplicationDocumentsDirectory
  WidgetsFlutterBinding.ensureInitialized();
  
  final apiManager = await ApiManager.create();
  
  // Login
  final loginRes = await apiManager.login(LoginRequest(
    email: 'wwwabdo77@gmail.com',
    password: '01008765502Abdo@',
  ));
  print('Login: ${loginRes.status} - ${loginRes.message}');
  
  // Choose Role
  final chooseRoleOk = await apiManager.chooseRole('Patient');
  print('ChooseRole: $chooseRoleOk');
  
  // Try to edit profile with empty address
  try {
    final success = await apiManager.editPatientProfile(
      fullName: 'Abdo',
      email: 'wwwabdo77@gmail.com',
      phoneNumber: '01008765502',
      address: '', // empty address
      gender: 'male',
      dateOfBirth: '01/01/2004',
    );
    print('Edit Profile Success: $success');
  } catch (e) {
    print('Edit Profile Threw Exception: $e');
  }
}
