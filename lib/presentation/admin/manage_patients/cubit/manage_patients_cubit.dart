import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repository/repository.dart';
import 'manage_patients_state.dart';

class ManagePatientsCubit extends Cubit<ManagePatientsState> {
  final Repository repository;
  List<dynamic> patientsList = [];
  
  ManagePatientsCubit(this.repository) : super(ManagePatientsInitial());

  Future<void> fetchPatients() async {
    emit(ManagePatientsLoading());
    try {
      final patients = await repository.adminGetAllPatients();
      patientsList = List.from(patients);
      emit(ManagePatientsLoaded(patients));
    } catch (e) {
      emit(ManagePatientsError(e.toString()));
    }
  }

  void restorePatientsList() {
    emit(ManagePatientsLoaded(patientsList));
  }

  Future<void> deletePatient(int patientId) async {
    final currentState = state;
    try {
      final success = await repository.adminDeletePatient(patientId);
      if (success) {
        patientsList.removeWhere((p) => (p['id'] ?? p['Id']) == patientId);
        if (currentState is ManagePatientsLoaded) {
          final updatedList = currentState.patients.where((p) => p['id'] != patientId).toList();
          emit(ManagePatientsLoaded(updatedList));
        } else {
          restorePatientsList();
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

  Future<void> togglePatientLock(int patientId) async {
    final currentState = state;
    emit(ManagePatientsOperationLoading());
    try {
      final success = await repository.adminTogglePatientLock(patientId);
      if (success) {
        emit(ManagePatientsOperationSuccess('Patient lock status toggled'));

        // Update the patient lock status locally in patientsList
        final index = patientsList.indexWhere((p) => (p['id'] ?? p['Id']) == patientId);
        if (index != -1) {
          final patient = patientsList[index];
          final currentIsLocked = (patient['lockoutEnd'] != null && 
              DateTime.tryParse(patient['lockoutEnd'].toString()) != null && 
              DateTime.parse(patient['lockoutEnd'].toString()).isAfter(DateTime.now())) ||
              (patient['LockoutEnd'] != null && 
              DateTime.tryParse(patient['LockoutEnd'].toString()) != null && 
              DateTime.parse(patient['LockoutEnd'].toString()).isAfter(DateTime.now()));
          
          final updatedPatient = Map<String, dynamic>.from(patient);
          if (currentIsLocked) {
            updatedPatient['lockoutEnd'] = null;
            updatedPatient['LockoutEnd'] = null;
          } else {
            final futureDate = DateTime.now().add(const Duration(days: 365)).toIso8601String();
            updatedPatient['lockoutEnd'] = futureDate;
            updatedPatient['LockoutEnd'] = futureDate;
          }
          patientsList[index] = updatedPatient;
        }

        if (currentState is ManagePatientsPatientDetailsLoaded) {
          final updatedPatient = Map<String, dynamic>.from(currentState.patient);
          final currentIsLocked = (updatedPatient['lockoutEnd'] != null && 
              DateTime.tryParse(updatedPatient['lockoutEnd'].toString()) != null && 
              DateTime.parse(updatedPatient['lockoutEnd'].toString()).isAfter(DateTime.now())) ||
              (updatedPatient['LockoutEnd'] != null && 
              DateTime.tryParse(updatedPatient['LockoutEnd'].toString()) != null && 
              DateTime.parse(updatedPatient['LockoutEnd'].toString()).isAfter(DateTime.now()));
          
          if (currentIsLocked) {
            updatedPatient['lockoutEnd'] = null;
            updatedPatient['LockoutEnd'] = null;
          } else {
            final futureDate = DateTime.now().add(const Duration(days: 365)).toIso8601String();
            updatedPatient['lockoutEnd'] = futureDate;
            updatedPatient['LockoutEnd'] = futureDate;
          }

          // Sync back to patientsList if it is there
          final idx = patientsList.indexWhere((p) => (p['id'] ?? p['Id']) == patientId);
          if (idx != -1) {
            patientsList[idx] = updatedPatient;
          }

          emit(ManagePatientsPatientDetailsLoaded(updatedPatient));
        } else {
          emit(ManagePatientsLoaded(List.from(patientsList)));
        }
        return;
      } else {
        emit(ManagePatientsOperationError('Failed to toggle patient lock'));
      }
    } catch (e) {
      emit(ManagePatientsOperationError(e.toString()));
    }
    if (currentState is ManagePatientsLoaded) {
      emit(ManagePatientsLoaded(currentState.patients));
    } else if (currentState is ManagePatientsPatientDetailsLoaded) {
      emit(ManagePatientsPatientDetailsLoaded(currentState.patient));
    }
  }

  Future<void> resetPatientPassword(int patientId, String newPassword, String confirmPassword) async {
    final currentState = state;
    emit(ManagePatientsOperationLoading());
    try {
      final success = await repository.adminResetPatientPassword(patientId, newPassword, confirmPassword);
      if (success) {
        emit(ManagePatientsOperationSuccess('Password reset successfully'));
      } else {
        emit(ManagePatientsOperationError('Failed to reset password'));
      }
    } catch (e) {
      emit(ManagePatientsOperationError(e.toString()));
    }
    if (currentState is ManagePatientsLoaded) {
      emit(ManagePatientsLoaded(currentState.patients));
    } else if (currentState is ManagePatientsPatientDetailsLoaded) {
      emit(ManagePatientsPatientDetailsLoaded(currentState.patient));
    }
  }

  Future<void> getPatientDetails(int patientId) async {
    final currentState = state;
    emit(ManagePatientsOperationLoading());
    try {
      final patient = await repository.adminGetPatient(patientId);
      if (patient != null) {
        final index = patientsList.indexWhere((p) => (p['id'] ?? p['Id']) == patientId);
        if (index != -1) {
          patientsList[index] = patient;
        }
        emit(ManagePatientsPatientDetailsLoaded(patient));
        return;
      } else {
        emit(ManagePatientsOperationError('Failed to load patient details'));
      }
    } catch (e) {
      emit(ManagePatientsOperationError(e.toString()));
    }
    if (currentState is ManagePatientsLoaded) {
      emit(ManagePatientsLoaded(currentState.patients));
    }
  }

  Future<void> editPatient(int patientId, Map<String, dynamic> data, String? imagePath) async {
    final currentState = state;
    emit(ManagePatientsOperationLoading());
    try {
      final success = await repository.adminEditPatient(patientId, data, imagePath);
      if (success) {
        emit(ManagePatientsOperationSuccess('Patient updated successfully'));
        getPatientDetails(patientId);
      } else {
        emit(ManagePatientsOperationError('Failed to edit patient'));
        if (currentState is ManagePatientsPatientDetailsLoaded) {
          emit(ManagePatientsPatientDetailsLoaded(currentState.patient));
        }
      }
    } catch (e) {
      emit(ManagePatientsOperationError(e.toString()));
      if (currentState is ManagePatientsPatientDetailsLoaded) {
        emit(ManagePatientsPatientDetailsLoaded(currentState.patient));
      }
    }
  }
}
