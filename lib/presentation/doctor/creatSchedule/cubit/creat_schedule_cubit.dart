import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduationproject/data/models/schudule/cliniceSchedual.dart';
import 'package:graduationproject/data/models/schudule/creatSchudel.dart';
import 'package:graduationproject/data/repository/scheduleRepository/clinic_repository.dart';
import 'package:graduationproject/data/repository/shared_pref_controller.dart';
import 'creat_schedule_state.dart';

class CreateScheduleCubit extends Cubit<CreateScheduleState> {
  final ClinicRepository clinicRepository;
  final SharedPrefController sharedPrefController;

  // لستة العيادات عشان متختفيش من الـ UI لما الحالة تتغير
  List<ClinicModel> clinics = [];

  // لستة كل المواعيد
  List<dynamic> allSchedules = [];

  CreateScheduleCubit({
    required this.clinicRepository,
    required this.sharedPrefController,
  }) : super(CreateScheduleInitial());

  // جلب العيادات المتاحة للطبيب (للـ add schedule form)
  Future<void> loadClinics() async {
    emit(CreateScheduleLoading());
    try {
      clinics = await clinicRepository.getDoctorClinics();
      if (clinics.isNotEmpty) {
        emit(CreateScheduleClinicsLoaded(clinics));
      } else {
        emit(
          const CreateScheduleError(
            "No clinics found. Please add a clinic first.",
          ),
        );
      }
    } catch (e) {
      emit(CreateScheduleError(e.toString()));
    }
  }

  // جلب كل المواعيد لكل العيادات (للـ manage schedule tab)
  Future<void> loadAllSchedules() async {
    emit(CreateScheduleLoading());
    try {
      try {
        clinics = await clinicRepository.getDoctorClinics();
      } catch (e) {
        final message = e.toString().replaceFirst('Exception: ', '').trim();
        emit(CreateScheduleError(
          message.isNotEmpty
              ? message
              : 'Failed to load clinics. Please try again.',
        ));
        return;
      }

      // 1. Try to fetch all schedules directly from the GetAllSchedules API
      List<dynamic> fetchedSchedules = [];
      try {
        fetchedSchedules = await clinicRepository.getAllSchedules();
      } catch (e) {
        print('Error calling getAllSchedules: $e');
      }

      final List<dynamic> schedules = [];

      if (fetchedSchedules.isNotEmpty) {
        print('=== Using schedules from GetAllSchedules API ===');
        for (final s in fetchedSchedules) {
          if (s is Map) {
            // Find clinic name if not present
            final clinicId = s['clinicId'] ?? s['ClinicId'];
            String? clinicName = s['clinicName'] ?? s['ClinicName'] ?? s['_clinicName'];
            if (clinicName == null && clinicId != null) {
              final cId = clinicId is int ? clinicId : int.tryParse(clinicId.toString());
              ClinicModel? matchingClinic;
              for (final c in clinics) {
                if (c.id == cId) {
                  matchingClinic = c;
                  break;
                }
              }
              clinicName = matchingClinic?.name;
            }
            var resolvedClinicId = clinicId;
            if (resolvedClinicId == null && clinicName != null) {
              for (final c in clinics) {
                if (c.name.trim().toLowerCase() == clinicName.trim().toLowerCase()) {
                  resolvedClinicId = c.id;
                  break;
                }
              }
            }
            if (resolvedClinicId == null && clinics.isNotEmpty) {
              resolvedClinicId = clinics.first.id;
            }
            schedules.add({
              ...s,
              '_clinicName': clinicName ?? 'Clinic',
              '_clinicId': resolvedClinicId,
            });
          } else {
            schedules.add(s);
          }
        }
      } else {
        // 2. Fallback to clinic-by-clinic fetching if API returned empty
        print('=== Falling back to clinic-by-clinic schedule fetching ===');
        for (final clinic in clinics) {
          if (clinic.id != null) {
            List<dynamic> targetSchedules = [];
            
            try {
              final fetched = await clinicRepository.getClinicSchedules(clinic.id!);
              if (fetched.isNotEmpty) {
                targetSchedules.addAll(fetched);
              }
            } catch (e) {
              // FOR DEBUGGING: If the error comes from our custom API throws, rethrow it to show in UI
              if (e.toString().contains('API Error') || e.toString().contains('API Map') || e.toString().contains('API Response')) {
                throw e;
              }
            }

            // Fallback: If fetched is empty, try to use schedules from the clinic model
            if (targetSchedules.isEmpty && clinic.schedules != null && clinic.schedules!.isNotEmpty) {
              targetSchedules.addAll(clinic.schedules!);
            }

            // Add to overall schedules
            for (final s in targetSchedules) {
              if (s is Map) {
                schedules.add({...s, '_clinicName': clinic.name, '_clinicId': clinic.id});
              } else {
                schedules.add(s);
              }
            }
          }
        }
      }
      
      allSchedules = schedules;
      emit(CreateScheduleAllLoaded(schedules: allSchedules, clinics: clinics));
    } catch (e) {
      emit(CreateScheduleError(e.toString()));
    }
  }

  // إضافة ميعاد جديد
  Future<void> addSchedule({
    required String day,
    required String startTime,
    required String endTime,
    required int clinicId,
  }) async {
    emit(CreateScheduleLoading());
    try {
      final model = CreateScheduleModel(
        day: day,
        startTime: startTime,
        endTime: endTime,
        clinicId: clinicId,
      );

      final success = await clinicRepository.createSchedule(model);

      if (success) {
        // إعطاء السيرفر وقت بسيط عشان يحفظ الداتا قبل ما نرجع نقرأها
        await Future.delayed(const Duration(milliseconds: 600));
        await loadAllSchedules();
        emit(CreateScheduleAddSuccess());
      } else {
        emit(
          const CreateScheduleError(
            "Failed to create schedule. Please check the data format.",
          ),
        );
      }
    } catch (e) {
      emit(CreateScheduleError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // حذف ميعاد
  Future<void> deleteSchedule(int scheduleId) async {
    emit(CreateScheduleLoading());
    try {
      final success = await clinicRepository.deleteSchedule(scheduleId);
      if (success) {
        await loadAllSchedules();
        emit(CreateScheduleDeleteSuccess());
      } else {
        emit(const CreateScheduleError("Failed to delete schedule."));
      }
    } catch (e) {
      emit(CreateScheduleError(e.toString()));
    }
  }

  // تعديل ميعاد
  Future<void> editScheduleEntry(editClinicModel model) async {
    emit(CreateScheduleLoading());
    try {
      final success = await clinicRepository.editSchedule(model);
      if (success) {
        await loadAllSchedules();
        emit(CreateScheduleEditSuccess());
      } else {
        emit(const CreateScheduleError("Failed to edit schedule."));
      }
    } catch (e) {
      emit(CreateScheduleError(e.toString()));
    }
  }
}

