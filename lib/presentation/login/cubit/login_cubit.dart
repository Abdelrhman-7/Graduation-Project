import 'package:flutter_bloc/flutter_bloc.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  bool isObscure = true;

  void togglePasswordVisibility() {
    isObscure = !isObscure;
    emit(LoginPasswordVisibilityChanged(isObscure));
  }

  void login(String email, String password) async {
    emit(LoginLoading());
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    emit(LoginSuccess());
  }
}
