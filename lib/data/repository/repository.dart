import '../api/api_manager.dart';
import '../models/login_model.dart';
import '../models/register_model.dart';
import '../models/logout_model.dart';

class Repository {
  Repository(this.apiManager);
  final ApiManager apiManager;

  Future<LoginResponse> login(String email, String password) async {
    return apiManager.login(LoginRequest(email: email, password: password));
  }

  Future<RegisterResponse> register({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required String address,
    required String gender,
    required String dateOfBirth,
    String? imageFile,
  }) async {
    return apiManager.register(
      RegisterRequest(
        fullName: fullName,
        userName: fullName.replaceAll(' ', ''), // Required for ASP.NET Identity
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        address: address,
        gender: gender,
        dateOfBirth: dateOfBirth,
        imageFile: imageFile,
      ),
    );
  }

  Future<RegisterResponse> forgetPassword(String email) async {
    return apiManager.forgetPassword(email);
  }

  Future<LogoutResponse> logout() async {
    return apiManager.logout();
  }

  Future<bool> chooseRole(String role) async {
    return apiManager.chooseRole(role);
  }
}
