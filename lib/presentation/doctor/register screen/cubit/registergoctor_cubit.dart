import 'package:bloc/bloc.dart';
import 'package:graduationproject/data/api/api_manager.dart';
import 'package:graduationproject/data/models/Auth/register_model.dart';

part 'cubit_state.dart';

class RegisterDoctorCubit extends Cubit<DoctorRegisterState> {
  final ApiManager apiManager;

  RegisterDoctorCubit(this.apiManager) : super(DoctorRegisterInitial());

  Future<void> registerDoctor({
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
    String? imageFile,
  }) async {
    emit(DoctorRegisterLoading());

    try {
      final request = RegisterRequest(
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
        imageFile: imageFile,
      );

      final result = await apiManager.register(
        request: request,
        isDoctor: true,
      );

      if (result.status == true) {
        emit(
          DoctorRegisterSuccess(message: result.message ?? 'Register Success'),
        );
      } else {
        emit(
          DoctorRegisterError(
            errorMessage: result.message ?? 'Register Failed',
          ),
        );
      }
    } catch (e) {
      emit(DoctorRegisterError(errorMessage: e.toString()));
    }
  }
}
