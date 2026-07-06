import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/repository/repository.dart';
import 'manage_patients_state.dart';

class ManagePatientsCubit extends Cubit<ManagePatientsState> {
  final Repository repository;
  List<dynamic> patientsList = [];
  static const String _lockPrefKey = 'patient_lock_';

  ManagePatientsCubit(this.repository) : super(ManagePatientsInitial());

  // ── SharedPrefs helpers for lock status ──────────────────────────────
  Future<void> _saveLockStatus(String patientId, bool isLocked) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_lockPrefKey$patientId', isLocked);
  }

  Future<bool?> _getSavedLockStatus(String patientId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_lockPrefKey$patientId');
  }

  // Apply saved lock override to a patient map
  Future<Map<String, dynamic>> _applyLockOverride(Map<String, dynamic> patient) async {
    final id = (patient['id'] ?? patient['Id']);
    if (id == null) return patient;
    final savedLock = await _getSavedLockStatus(id.toString());
    if (savedLock == null) return patient; // No override saved, use API value
    final updated = Map<String, dynamic>.from(patient);
    if (savedLock) {
      final futureDate = DateTime.now().add(const Duration(days: 365)).toIso8601String();
      updated['lockoutEnd'] = futureDate;
      updated['LockoutEnd'] = futureDate;
    } else {
      updated['lockoutEnd'] = null;
      updated['LockoutEnd'] = null;
    }
    return updated;
  }

  bool _isPatientLocked(Map<String, dynamic> patient) {
    final val = patient['lockoutEnd'] ?? patient['LockoutEnd'];
    return val != null &&
        DateTime.tryParse(val.toString()) != null &&
        DateTime.parse(val.toString()).isAfter(DateTime.now());
  }
  // ─────────────────────────────────────────────────────────────────────

  Future<void> fetchPatients() async {
    emit(ManagePatientsLoading());
    try {
      final rawPatients = await repository.adminGetAllPatients();
      // Apply saved lock overrides to each patient
      final patients = await Future.wait(
        rawPatients.map((p) => _applyLockOverride(Map<String, dynamic>.from(p))),
      );
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
        bool newIsLocked = false;

        if (index != -1) {
          final patient = patientsList[index];
          final currentIsLocked = _isPatientLocked(patient);
          newIsLocked = !currentIsLocked;

          final updatedPatient = Map<String, dynamic>.from(patient);
          if (newIsLocked) {
            final futureDate = DateTime.now().add(const Duration(days: 365)).toIso8601String();
            updatedPatient['lockoutEnd'] = futureDate;
            updatedPatient['LockoutEnd'] = futureDate;
          } else {
            updatedPatient['lockoutEnd'] = null;
            updatedPatient['LockoutEnd'] = null;
          }
          patientsList[index] = updatedPatient;
        }

        // ── دايماً احفظ الحالة الجديدة في SharedPrefs ──
        if (currentState is ManagePatientsPatientDetailsLoaded) {
          final updatedPatient = Map<String, dynamic>.from(currentState.patient);
          final currentIsLocked = _isPatientLocked(updatedPatient);
          newIsLocked = !currentIsLocked;

          if (newIsLocked) {
            final futureDate = DateTime.now().add(const Duration(days: 365)).toIso8601String();
            updatedPatient['lockoutEnd'] = futureDate;
            updatedPatient['LockoutEnd'] = futureDate;
          } else {
            updatedPatient['lockoutEnd'] = null;
            updatedPatient['LockoutEnd'] = null;
          }

          // Sync back to patientsList
          final idx = patientsList.indexWhere((p) => (p['id'] ?? p['Id']) == patientId);
          if (idx != -1) {
            patientsList[idx] = updatedPatient;
          }

          await _saveLockStatus(patientId.toString(), newIsLocked);
          emit(ManagePatientsPatientDetailsLoaded(updatedPatient));
        } else {
          await _saveLockStatus(patientId.toString(), newIsLocked);
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
      final rawPatient = await repository.adminGetPatient(patientId);
      if (rawPatient != null) {
        // Apply saved lock override on top of API data
        final patient = await _applyLockOverride(Map<String, dynamic>.from(rawPatient));
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
