import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduationproject/data/models/schudule/cliniceSchedual.dart';
import 'package:graduationproject/data/models/schudule/creatSchudel.dart';
import 'package:graduationproject/data/repository/scheduleRepository/clinic_repository.dart';
import 'package:graduationproject/data/repository/shared_pref_controller.dart';

import 'doctor_clinics_state.dart';

class DoctorClinicsCubit extends Cubit<DoctorClinicsState> {
  final ClinicRepository clinicRepository;
  final SharedPrefController _sharedPrefController = SharedPrefController();

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
        // Save duration and notes locally because the API does not return them
        if (clinic.id != null) {
          await _sharedPrefController.saveClinicLocalData(
            clinic.id!,
            clinic.appointmentDuration,
            clinic.nots,
          );
        }

        // Clean and update the schedules for this clinic to match the new duration and notes on the server
        if (clinic.schedules != null && clinic.id != null) {
          final cleanDur =
              RegExp(r'\d+').firstMatch(clinic.appointmentDuration)?.group(0) ??
              '30';
          for (final sched in clinic.schedules!) {
            if (sched is Map) {
              final schedId = sched['id'] ?? sched['Id'];
              if (schedId != null) {
                final editModel = editClinicModel(
                  id: schedId,
                  clinicId: clinic.id.toString(),
                  day:
                      sched['dayOfWeek'] ??
                      sched['DayOfWeek'] ??
                      sched['day'] ??
                      sched['Day'],
                  startTime: sched['startTime'] ?? sched['StartTime'],
                  endTime: sched['endTime'] ?? sched['EndTime'],
                  appointmentDuration: cleanDur,
                  nots: clinic.nots,
                );
                await clinicRepository.editSchedule(editModel);
              }
            }
          }
        }
        await loadClinics();
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

      // Fetch all schedules for this doctor to filter them for each clinic
      List<dynamic> allSchedules = [];
      try {
        allSchedules = await clinicRepository.getAllSchedules();
        print(
          '===== loadClinics: fetched ${allSchedules.length} total doctor schedules =====',
        );
      } catch (e) {
        print('Error fetching doctor schedules: $e');
      }

      // لكل عيادة نجيب جدول المواعيد الخاص بها
      final List<ClinicModel> enriched = [];
      for (final clinic in rawClinics) {
        List<dynamic> schedules = clinic.schedules ?? [];
        print(
          'Clinic "${clinic.name}" (id=${clinic.id}): embedded schedules = ${schedules.length}',
        );

        // لو السيرفر مش بيرجع schedules جوّا بيانات العيادة، نفلترها من القائمة الكلية لجدول المواعيد
        if (schedules.isEmpty && clinic.id != null) {
          final cId = clinic.id;
          schedules = allSchedules.where((s) {
            if (s is Map) {
              final id = s['clinicId'] ?? s['ClinicId'];
              final parsedId = id is int
                  ? id
                  : int.tryParse(id?.toString() ?? '');
              return parsedId == cId;
            }
            return false;
          }).toList();
          print(
            '  -> Filtered ${schedules.length} schedules from doctor schedules list',
          );
        }

        // Resolve duration and notes from local preferences
        String resolvedDuration = '30 mins';
        String resolvedNotes = '';
        if (clinic.id != null) {
          final localData = await _sharedPrefController.getClinicLocalData(
            clinic.id!,
          );
          resolvedDuration = localData['duration'] ?? '30 mins';
          resolvedNotes = localData['notes'] ?? '';
        }

        enriched.add(
          ClinicModel(
            id: clinic.id,
            name: clinic.name,
            address: clinic.address,
            phoneNumber: clinic.phoneNumber,
            consultationPrice: clinic.consultationPrice,
            createdAt: clinic.createdAt,
            appointmentDuration: resolvedDuration,
            nots: resolvedNotes,
            schedules: schedules,
          ),
        );
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
