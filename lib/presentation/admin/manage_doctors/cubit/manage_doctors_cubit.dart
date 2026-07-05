import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repository/repository.dart';
import 'manage_doctors_state.dart';

class ManageDoctorsCubit extends Cubit<ManageDoctorsState> {
  final Repository repository;
  List<dynamic> doctorsList = [];
  
  ManageDoctorsCubit(this.repository) : super(ManageDoctorsInitial());

  Future<void> fetchDoctors() async {
    emit(ManageDoctorsLoading());
    try {
      final doctors = await repository.adminGetAllDoctors();
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
        if (index != -1) {
          final doctor = doctorsList[index];
          final currentIsLocked = (doctor['lockoutEnd'] != null && 
              DateTime.tryParse(doctor['lockoutEnd'].toString()) != null && 
              DateTime.parse(doctor['lockoutEnd'].toString()).isAfter(DateTime.now())) ||
              (doctor['LockoutEnd'] != null && 
              DateTime.tryParse(doctor['LockoutEnd'].toString()) != null && 
              DateTime.parse(doctor['LockoutEnd'].toString()).isAfter(DateTime.now()));
          
          final updatedDoctor = Map<String, dynamic>.from(doctor);
          if (currentIsLocked) {
            updatedDoctor['lockoutEnd'] = null;
            updatedDoctor['LockoutEnd'] = null;
          } else {
            final futureDate = DateTime.now().add(const Duration(days: 365)).toIso8601String();
            updatedDoctor['lockoutEnd'] = futureDate;
            updatedDoctor['LockoutEnd'] = futureDate;
          }
          doctorsList[index] = updatedDoctor;
        }

        if (currentState is ManageDoctorsDoctorDetailsLoaded) {
          final updatedDoctor = Map<String, dynamic>.from(currentState.doctor);
          final currentIsLocked = (updatedDoctor['lockoutEnd'] != null && 
              DateTime.tryParse(updatedDoctor['lockoutEnd'].toString()) != null && 
              DateTime.parse(updatedDoctor['lockoutEnd'].toString()).isAfter(DateTime.now())) ||
              (updatedDoctor['LockoutEnd'] != null && 
              DateTime.tryParse(updatedDoctor['LockoutEnd'].toString()) != null && 
              DateTime.parse(updatedDoctor['LockoutEnd'].toString()).isAfter(DateTime.now()));
          
          if (currentIsLocked) {
            updatedDoctor['lockoutEnd'] = null;
            updatedDoctor['LockoutEnd'] = null;
          } else {
            final futureDate = DateTime.now().add(const Duration(days: 365)).toIso8601String();
            updatedDoctor['lockoutEnd'] = futureDate;
            updatedDoctor['LockoutEnd'] = futureDate;
          }

          // Sync back to doctorsList if it is there
          final idx = doctorsList.indexWhere((d) => (d['id'] ?? d['Id']) == doctorId);
          if (idx != -1) {
            doctorsList[idx] = updatedDoctor;
          }

          emit(ManageDoctorsDoctorDetailsLoaded(updatedDoctor));
        } else {
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

  Future<void> resetDoctorPassword(int doctorId, String newPassword, String confirmPassword) async {
    final currentState = state;
    emit(ManageDoctorsOperationLoading());
    try {
      final success = await repository.adminResetDoctorPassword(doctorId, newPassword, confirmPassword);
      if (success) {
        emit(ManageDoctorsOperationSuccess('Password reset successfully'));
        // Restore state after success so the UI doesn't stay in success state if needed
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
      final doctor = await repository.adminGetDoctor(doctorId);
      if (doctor != null) {
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
