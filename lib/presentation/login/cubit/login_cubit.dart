import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/api/api_manager.dart';
import '../../../data/models/Auth/login_model.dart';
import '../../../data/repository/shared_pref_controller.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final ApiManager _apiService;
  final SharedPrefController _prefController;
  LoginCubit(this._apiService, this._prefController) : super(LoginInitial());
  bool isObscure = true;
  void togglePasswordVisibility() {
    isObscure = !isObscure;
    emit(LoginPasswordVisibilityChanged());
  }

  Future<void> login(LoginRequest request, String role) async {
    emit(LoginLoading());
    try {
      final response = await _apiService.login(request);
      if (response.status == true) {
        await _prefController.saveLogin(request.email);
        final fullName = response.data?.fullName;
        if (fullName != null && fullName.isNotEmpty) {
          await _prefController.saveUserInfo(fullName, null);
        }
        final token = response.data?.token;
        if (token != null && token.isNotEmpty) {
          await _prefController.saveToken(token);
        }
        // Bind the role on the server for this session
        final String activeRole = request.email.trim().toLowerCase() == 'admin@gmail.com' ? 'Admin' : role;
        await _prefController.saveRole(activeRole);
        await _apiService.chooseRole(activeRole);
        emit(LoginSuccess(response));
      } else {
        emit(LoginError(response.message ?? 'Login failed'));
      }
    } catch (e) {
      emit(LoginError(e.toString()));
    }
  }
}
