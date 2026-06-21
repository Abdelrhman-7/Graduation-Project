import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduationproject/data/models/schudule/cliniceSchedual.dart';
import 'package:graduationproject/data/models/schudule/creatSchudel.dart';
import 'package:graduationproject/data/repository/scheduleRepository/clinic_repository.dart';

import 'doctor_clinics_state.dart';

class DoctorClinicsCubit extends Cubit<DoctorClinicsState> {
  final ClinicRepository clinicRepository;

  DoctorClinicsCubit({required this.clinicRepository})
    : super(DoctorClinicsInitial());

  List<ClinicModel> clinics = [];

  Future<void> editClinic(editClinicModel clinic) async {
    emit(DoctorClinicsLoading());
    try {
      final success = await clinicRepository.editSchedule(clinic);
      if (success) {
        emit(DoctorClinicsSuccess(clinics: clinics));
      } else {
        emit(DoctorClinicsError(message: "Failed to edit schedule"));
      }
    } catch (e) {
      emit(DoctorClinicsError(message: e.toString()));
    }
  }

  Future<void> updateClinic(ClinicModel clinic) async {
    emit(DoctorClinicsLoading());
    try {
      final success = await clinicRepository.updateClinic(clinic);
      if (success) {
        final index = clinics.indexWhere((c) => c.id == clinic.id);
        if (index != -1) {
          clinics[index] = clinic;
        }
        emit(DoctorClinicsSuccess(clinics: List.from(clinics)));
      } else {
        emit(DoctorClinicsError(message: "Failed to update clinic"));
      }
    } catch (e) {
      emit(DoctorClinicsError(message: e.toString()));
    }
  }

  Future<void> loadClinics() async {
    emit(DoctorClinicsLoading());
    try {
      final rawClinics = await clinicRepository.getDoctorClinics();
      print('===== loadClinics: got ${rawClinics.length} clinics =====');

      // لكل عيادة نجيب جدول المواعيد الخاص بها
      final List<ClinicModel> enriched = [];
      for (final clinic in rawClinics) {
        List<dynamic> schedules = clinic.schedules ?? [];
        print('Clinic "${clinic.name}" (id=${clinic.id}): embedded schedules = ${schedules.length}');
        
        // لو السيرفر مش بيرجع schedules جوّا بيانات العيادة، نجيبها منفصلة
        if (schedules.isEmpty && clinic.id != null) {
          print('  -> Fetching schedules separately for clinic ${clinic.id}...');
          schedules = await clinicRepository.getClinicSchedules(clinic.id!);
          print('  -> Got ${schedules.length} schedules from separate API');
          if (schedules.isNotEmpty) {
            print('  -> First schedule: ${schedules[0]}');
          }
        }
        enriched.add(ClinicModel(
          id: clinic.id,
          name: clinic.name,
          address: clinic.address,
          phoneNumber: clinic.phoneNumber,
          consultationPrice: clinic.consultationPrice,
          createdAt: clinic.createdAt,
          appointmentDuration: clinic.appointmentDuration,
          nots: clinic.nots,
          schedules: schedules,
        ));
      }

      clinics = enriched;
      emit(DoctorClinicsSuccess(clinics: clinics));
    } catch (e) {
      emit(DoctorClinicsError(message: e.toString()));
    }
  }

  Future<void> deleteClinic(int id) async {
    emit(DoctorClinicsLoading());
    try {
      final success = await clinicRepository.deleteClinic(id);
      if (success) {
        clinics.removeWhere((c) => c.id == id);
        emit(DoctorClinicsSuccess(clinics: List.from(clinics)));
      } else {
        emit(DoctorClinicsError(message: "Failed to delete clinic"));
      }
    } catch (e) {
      emit(DoctorClinicsError(message: e.toString()));
    }
  }
}
