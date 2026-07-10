import 'package:bloc/bloc.dart';
import 'package:graduationproject/data/api/api_manager.dart';
import 'package:graduationproject/data/models/Auth/register_model.dart';

part 'doctor_register_state.dart';

class DoctorRegisterCubit extends Cubit<DoctorRegisterState> {
  final ApiManager _api;

  DoctorRegisterCubit(this._api) : super(DoctorRegisterInitial());

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
    required String phoneNumber,
    required String address,
    required String gender,
    required String dateOfBirth,
    required int departmentId,
    required String aboutMe,
  }) async {
    emit(DoctorRegisterLoading());

    try {
      final result = await _api.register(
        request: RegisterRequest(
          fullName: fullName,
          email: email,
          password: password,
          confirmPassword: confirmPassword,
          phoneNumber: phoneNumber,
          address: address,
          gender: gender,
          dateOfBirth: dateOfBirth,
          departmentId: departmentId,
          aboutMe: aboutMe,
        ),
        isDoctor: true,
      );

      if (result.status == true) {
        emit(DoctorRegisterSuccess(
          message: result.message ?? 'Registration successful!',
        ));
      } else {
        emit(DoctorRegisterError(
          message: result.message ?? 'Registration failed. Please try again.',
        ));
      }
    } catch (e) {
      emit(DoctorRegisterError(message: e.toString()));
    }
  }
}
