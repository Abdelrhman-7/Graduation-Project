import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduationproject/data/repository/repository.dart';
import 'patient_emergency_state.dart';

class PatientEmergencyCubit extends Cubit<PatientEmergencyState> {
  final Repository repository;

  PatientEmergencyCubit(this.repository) : super(PatientEmergencyInitial());

  // Function to simulate a call or action
  void callEmergencyService() async {
    emit(PatientEmergencyLoading());
    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network or action delay
      emit(PatientEmergencySuccess());
    } catch (e) {
      emit(PatientEmergencyError('Failed to connect to emergency service.'));
    }
  }
}
