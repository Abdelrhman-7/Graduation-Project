import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/api/api_manager.dart';
import '../../../data/models/Auth/register_model.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final ApiManager _apiService;

  RegisterCubit(this._apiService) : super(RegisterInitial());

  Future<void> register(RegisterRequest request) async {
    emit(RegisterLoading());
    try {
      // The ASP.NET backend uses fullName as UserName — spaces cause 400 errors
      // ignore: unused_local_variable
      final sanitizedRequest = RegisterRequest(
        fullName: request.fullName,
        userName: request.fullName.replaceAll(' ', ''),
        email: request.email,
        password: request.password,
        confirmPassword: request.confirmPassword,
        phoneNumber: request.phoneNumber,
        address: request.address,
        gender: request.gender,
        dateOfBirth: request.dateOfBirth,
        imageFile: request.imageFile,
      );

      final result = await _apiService.register(
        request: request,
        isDoctor: false,
      );

      if (result.status == true) {
        emit(RegisterSuccess(result.message));
      } else {
        emit(RegisterError(result.message ?? 'Registration failed'));
      }
    } catch (e) {
      print('Register error: $e');
      emit(RegisterError(e.toString()));
    }
  }
}
