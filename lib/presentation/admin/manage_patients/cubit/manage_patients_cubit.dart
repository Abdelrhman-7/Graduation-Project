import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repository/repository.dart';
import 'manage_patients_state.dart';

class ManagePatientsCubit extends Cubit<ManagePatientsState> {
  final Repository repository;
  
  ManagePatientsCubit(this.repository) : super(ManagePatientsInitial());

  Future<void> fetchPatients() async {
    emit(ManagePatientsLoading());
    try {
      final patients = await repository.adminGetAllPatients();
      emit(ManagePatientsLoaded(patients));
    } catch (e) {
      emit(ManagePatientsError(e.toString()));
    }
  }

  Future<void> deletePatient(int patientId) async {
    final currentState = state;
    try {
      final success = await repository.adminDeletePatient(patientId);
      if (success) {
        if (currentState is ManagePatientsLoaded) {
          final updatedList = currentState.patients.where((p) => p['id'] != patientId).toList();
          emit(ManagePatientsLoaded(updatedList));
        } else {
          fetchPatients();
        }
      } else {
        emit(ManagePatientsError('Failed to delete patient'));
        if (currentState is ManagePatientsLoaded) {
          emit(ManagePatientsLoaded(currentState.patients));
        }
      }
    } catch (e) {
      emit(ManagePatientsError(e.toString()));
      if (currentState is ManagePatientsLoaded) {
        emit(ManagePatientsLoaded(currentState.patients));
      }
    }
  }
}
