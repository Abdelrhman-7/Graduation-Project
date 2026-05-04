import 'package:flutter_bloc/flutter_bloc.dart';

part 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit() : super(ForgotPasswordInitial());

  void resetPassword(String email) async {
    emit(ForgotPasswordLoading());
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    emit(ForgotPasswordSuccess());
  }
}
