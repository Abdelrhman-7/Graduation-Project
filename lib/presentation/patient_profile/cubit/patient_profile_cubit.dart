import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repository/repository.dart';
import '../../../data/repository/shared_pref_controller.dart';
import 'patient_profile_state.dart';

class PatientProfileCubit extends Cubit<PatientProfileState> {
  final Repository repository;
  final SharedPrefController sharedPrefController;

  PatientProfileCubit({
    required this.repository,
    required this.sharedPrefController,
  }) : super(PatientProfileInitial());

  void getProfileData() async {
    emit(PatientProfileLoading());
    try {
      // Get data from SharedPrefs or API
      // ignore: unused_local_variable
      final email = await sharedPrefController.getEmail() ?? 'N/A';

      // Mocking API call for other fields
      await Future.delayed(const Duration(milliseconds: 300));
      emit(
        PatientProfileSuccess(
          name: 'Alex Rivera',
          patientId: 'PT-882941',
          age: '28',
          bloodType: 'O+',
          dateOfBirth: '05/12/1996',
          medicalHistory: 'Hypertension (Controlled)',
          allergies: 'Penicillin, Peanuts',
        ),
      );
    } catch (e) {
      emit(PatientProfileError(e.toString()));
    }
  }

  void logout() async {
    emit(PatientProfileLoading());
    try {
      final response = await repository.logout();
      if (response.status) {
        await sharedPrefController.logout();
        emit(LogoutSuccess());
      } else {
        emit(PatientProfileError(response.message));
      }
    } catch (e) {
      emit(PatientProfileError(e.toString()));
    }
  }
}
