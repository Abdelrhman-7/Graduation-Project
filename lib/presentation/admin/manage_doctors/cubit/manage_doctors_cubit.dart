import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repository/repository.dart';
import 'manage_doctors_state.dart';

class ManageDoctorsCubit extends Cubit<ManageDoctorsState> {
  final Repository repository;
  
  ManageDoctorsCubit(this.repository) : super(ManageDoctorsInitial());

  Future<void> fetchDoctors() async {
    emit(ManageDoctorsLoading());
    try {
      final doctors = await repository.adminGetAllDoctors();
      emit(ManageDoctorsLoaded(doctors));
    } catch (e) {
      emit(ManageDoctorsError(e.toString()));
    }
  }

  Future<void> deleteDoctor(int doctorId) async {
    final currentState = state;
    try {
      final success = await repository.adminDeleteDoctor(doctorId);
      if (success) {
        if (currentState is ManageDoctorsLoaded) {
          final updatedList = currentState.doctors.where((d) => d['id'] != doctorId).toList();
          emit(ManageDoctorsLoaded(updatedList));
        } else {
          fetchDoctors();
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
}
