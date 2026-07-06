import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/repository/repository.dart';
import 'manage_doctors_state.dart';

class ManageDoctorsCubit extends Cubit<ManageDoctorsState> {
  final Repository repository;
  List<dynamic> doctorsList = [];
  static const String _lockPrefKey = 'doctor_lock_';
  
  ManageDoctorsCubit(this.repository) : super(ManageDoctorsInitial());

  // ── SharedPrefs helpers for lock status ──────────────────────────────
  Future<void> _saveLockStatus(String doctorId, bool isLocked) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_lockPrefKey$doctorId', isLocked);
  }

  Future<bool?> _getSavedLockStatus(String doctorId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_lockPrefKey$doctorId');
  }

  // Apply saved lock override to a doctor map
  Future<Map<String, dynamic>> _applyLockOverride(Map<String, dynamic> doctor) async {
    final id = (doctor['id'] ?? doctor['Id']);
    if (id == null) return doctor;
    final savedLock = await _getSavedLockStatus(id.toString());
    if (savedLock == null) return doctor; // No override saved, use API value
    final updated = Map<String, dynamic>.from(doctor);
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
  // ─────────────────────────────────────────────────────────────────────


  Future<void> fetchDoctors() async {
    emit(ManageDoctorsLoading());
    try {
      final rawDoctors = await repository.adminGetAllDoctors();
      // Apply saved lock overrides to each doctor
      final doctors = await Future.wait(
        rawDoctors.map((d) => _applyLockOverride(Map<String, dynamic>.from(d))),
      );
      doctorsList = List.from(doctors);
      emit(ManageDoctorsLoaded(doctors));
    } catch (e) {
      emit(ManageDoctorsError(e.toString()));
    }
  }

  void restoreDoctorsList() {
    emit(ManageDoctorsLoaded(doctorsList));
  }

  Future<void> deleteDoctor(int doctorId) async {
    final currentState = state;
    try {
      final success = await repository.adminDeleteDoctor(doctorId);
      if (success) {
        doctorsList.removeWhere((d) => (d['id'] ?? d['Id']) == doctorId);
        if (currentState is ManageDoctorsLoaded) {
          final updatedList = currentState.doctors.where((d) => d['id'] != doctorId).toList();
          emit(ManageDoctorsLoaded(updatedList));
        } else {
          restoreDoctorsList();
        }
      } else {
        emit(ManageDoctorsError('Failed to delete doctor'));
        if (currentState is ManageDoctorsLoaded) {
          emit(ManageDoctorsLoaded(currentState.doctors));
        }
      }
    } catch (e) {
      emit(ManageDoctorsError(e.toString()));
      if (currentState is ManageDoctorsLoaded) {
        emit(ManageDoctorsLoaded(currentState.doctors));
      }
    }
  }

  Future<void> toggleDoctorLock(int doctorId) async {
    final currentState = state;
    emit(ManageDoctorsOperationLoading());
    try {
      final success = await repository.adminToggleDoctorLock(doctorId);
      if (success) {
        emit(ManageDoctorsOperationSuccess('Doctor lock status toggled'));

        // Update the doctor lock status locally in doctorsList
        final index = doctorsList.indexWhere((d) => (d['id'] ?? d['Id']) == doctorId);
        bool newIsLocked = false;

        if (index != -1) {
          final doctor = doctorsList[index];
          final currentIsLocked = _isDocLocked(doctor);
          newIsLocked = !currentIsLocked;

          final updatedDoctor = Map<String, dynamic>.from(doctor);
          if (newIsLocked) {
            final futureDate = DateTime.now().add(const Duration(days: 365)).toIso8601String();
            updatedDoctor['lockoutEnd'] = futureDate;
            updatedDoctor['LockoutEnd'] = futureDate;
          } else {
            updatedDoctor['lockoutEnd'] = null;
            updatedDoctor['LockoutEnd'] = null;
          }
          doctorsList[index] = updatedDoctor;
        }

        // ── دايماً احفظ الحالة الجديدة في SharedPrefs ──
        if (currentState is ManageDoctorsDoctorDetailsLoaded) {
          final updatedDoctor = Map<String, dynamic>.from(currentState.doctor);
          final currentIsLocked = _isDocLocked(updatedDoctor);
          newIsLocked = !currentIsLocked;

          if (newIsLocked) {
            final futureDate = DateTime.now().add(const Duration(days: 365)).toIso8601String();
            updatedDoctor['lockoutEnd'] = futureDate;
            updatedDoctor['LockoutEnd'] = futureDate;
          } else {
            updatedDoctor['lockoutEnd'] = null;
            updatedDoctor['LockoutEnd'] = null;
          }

          // Sync back to doctorsList
          final idx = doctorsList.indexWhere((d) => (d['id'] ?? d['Id']) == doctorId);
          if (idx != -1) {
            doctorsList[idx] = updatedDoctor;
          }

          await _saveLockStatus(doctorId.toString(), newIsLocked);
          emit(ManageDoctorsDoctorDetailsLoaded(updatedDoctor));
        } else {
          await _saveLockStatus(doctorId.toString(), newIsLocked);
          emit(ManageDoctorsLoaded(List.from(doctorsList)));
        }
        return;
      } else {
        emit(ManageDoctorsOperationError('Failed to toggle doctor lock'));
      }
    } catch (e) {
      emit(ManageDoctorsOperationError(e.toString()));
    }
    if (currentState is ManageDoctorsLoaded) {
      emit(ManageDoctorsLoaded(currentState.doctors));
    } else if (currentState is ManageDoctorsDoctorDetailsLoaded) {
      emit(ManageDoctorsDoctorDetailsLoaded(currentState.doctor));
    }
  }

  bool _isDocLocked(Map<String, dynamic> doctor) {
    final val = doctor['lockoutEnd'] ?? doctor['LockoutEnd'];
    return val != null &&
        DateTime.tryParse(val.toString()) != null &&
        DateTime.parse(val.toString()).isAfter(DateTime.now());
  }

  Future<void> resetDoctorPassword(int doctorId, String newPassword, String confirmPassword) async {
    final currentState = state;
    emit(ManageDoctorsOperationLoading());
    try {
      final success = await repository.adminResetDoctorPassword(doctorId, newPassword, confirmPassword);
      if (success) {
        emit(ManageDoctorsOperationSuccess('Password reset successfully'));
      } else {
        emit(ManageDoctorsOperationError('Failed to reset password'));
      }
    } catch (e) {
      emit(ManageDoctorsOperationError(e.toString()));
    }
    if (currentState is ManageDoctorsLoaded) {
      emit(ManageDoctorsLoaded(currentState.doctors));
    } else if (currentState is ManageDoctorsDoctorDetailsLoaded) {
      emit(ManageDoctorsDoctorDetailsLoaded(currentState.doctor));
    }
  }

  Future<void> getDoctorDetails(int doctorId) async {
    final currentState = state;
    emit(ManageDoctorsOperationLoading());
    try {
      final rawDoctor = await repository.adminGetDoctor(doctorId);
      if (rawDoctor != null) {
        // Apply saved lock override on top of API data
        final doctor = await _applyLockOverride(Map<String, dynamic>.from(rawDoctor));
        final index = doctorsList.indexWhere((d) => (d['id'] ?? d['Id']) == doctorId);
        if (index != -1) {
          doctorsList[index] = doctor;
        }
        emit(ManageDoctorsDoctorDetailsLoaded(doctor));
        return; // Don't emit previous state
      } else {
        emit(ManageDoctorsOperationError('Failed to load doctor details'));
      }
    } catch (e) {
      emit(ManageDoctorsOperationError(e.toString()));
    }
    if (currentState is ManageDoctorsLoaded) {
      emit(ManageDoctorsLoaded(currentState.doctors));
    }
  }

  Future<void> editDoctor(int doctorId, Map<String, dynamic> data, String? imagePath) async {
    final currentState = state;
    emit(ManageDoctorsOperationLoading());
    try {
      final success = await repository.adminEditDoctor(doctorId, data, imagePath);
      if (success) {
        emit(ManageDoctorsOperationSuccess('Doctor updated successfully'));
        // Re-fetch details if we were showing them
        getDoctorDetails(doctorId);
      } else {
        emit(ManageDoctorsOperationError('Failed to edit doctor'));
        if (currentState is ManageDoctorsDoctorDetailsLoaded) {
          emit(ManageDoctorsDoctorDetailsLoaded(currentState.doctor));
        }
      }
    } catch (e) {
      emit(ManageDoctorsOperationError(e.toString()));
      if (currentState is ManageDoctorsDoctorDetailsLoaded) {
        emit(ManageDoctorsDoctorDetailsLoaded(currentState.doctor));
      }
    }
  }
}
