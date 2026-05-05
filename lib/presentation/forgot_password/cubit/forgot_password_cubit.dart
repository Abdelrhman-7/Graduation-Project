import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/api/api_manager.dart';

part 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final ApiManager _apiService;

  ForgotPasswordCubit(this._apiService) : super(ForgotPasswordInitial());

  Future<void> resetPassword(String email) async {
    emit(ForgotPasswordLoading());
    try {
      final result = await _apiService.forgetPassword(email);
      if (result.status == true) {
        emit(ForgotPasswordSuccess());
      } else {
        emit(ForgotPasswordError(result.message ?? 'Error resetting password'));
      }
    } catch (e) {
      emit(ForgotPasswordError(e.toString()));
    }
  }
}
