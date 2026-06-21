import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduationproject/data/repository/repository.dart';
import 'patient_booking_state.dart';

class PatientBookingCubit extends Cubit<PatientBookingState> {
  final Repository repository;

  PatientBookingCubit(this.repository) : super(PatientBookingInitial());

  // Old flow support if needed
  Future<void> fetchClinics() async {
    emit(PatientBookingLoading());
    try {
      final clinics = await repository.getPatientAllClinics();
      emit(PatientBookingSuccess(clinics));
    } catch (e) {
      emit(PatientBookingError(e.toString()));
    }
  }

  // Old flow support if needed
  Future<bool> bookAppointment({
    required int clinicId,
    required String date,
    required String timeSlot,
  }) async {
    final currentState = state;
    try {
      emit(PatientBookingBooking());
      final result = await repository.createPatientBooking(
        clinicId: clinicId,
        date: date,
        timeSlot: timeSlot,
      );
      if (currentState is PatientBookingSuccess) {
        emit(PatientBookingSuccess(currentState.clinics));
      }
      return result;
    } catch (e) {
      if (currentState is PatientBookingSuccess) {
        emit(PatientBookingSuccess(currentState.clinics));
      }
      return false;
    }
  }

  // --- NEW WORKFLOW METHODS ---

  /// جلب كل الأطباء
  Future<void> fetchDoctors() async {
    emit(PatientBookingLoading());
    try {
      final doctors = await repository.getPatientDoctors();
      emit(PatientBookingDoctorsSuccess(doctors));
    } catch (e) {
      emit(PatientBookingError(e.toString()));
    }
  }

  /// جلب تفاصيل طبيب معين
  Future<void> fetchDoctorDetails(int doctorId) async {
    emit(PatientBookingLoading());
    try {
      final doctor = await repository.getPatientDoctorDetails(doctorId);
      if (doctor != null) {
        emit(PatientBookingDoctorDetailsSuccess(doctor));
      } else {
        emit(PatientBookingError('Doctor details not found.'));
      }
    } catch (e) {
      emit(PatientBookingError(e.toString()));
    }
  }

  /// جلب عيادات طبيب معين
  Future<void> fetchDoctorClinics(int doctorId) async {
    emit(PatientBookingLoading());
    try {
      final clinics = await repository.getPatientDoctorClinics(doctorId);
      emit(PatientBookingClinicsSuccess(clinics));
    } catch (e) {
      emit(PatientBookingError(e.toString()));
    }
  }

  /// جلب مواعيد عيادة معينة لطبيب معين
  Future<void> fetchClinicSchedules(int clinicId, int doctorId) async {
    emit(PatientBookingLoading());
    try {
      final schedules = await repository.apiManager.getPatientClinicSchedules(
        clinicId: clinicId,
        doctorId: doctorId,
      );
      emit(PatientBookingSchedulesSuccess(schedules));
    } catch (e) {
      emit(PatientBookingError(e.toString()));
    }
  }

  /// حجز موعد
  Future<bool> bookPatientAppointment({
    required int scheduleId,
    required String reasonForVisit,
    required String paymentMethod,
  }) async {
    final currentState = state;
    emit(PatientBookingBooking());
    try {
      final result = await repository.bookPatientAppointment(
        scheduleId: scheduleId,
        reasonForVisit: reasonForVisit,
        paymentMethod: paymentMethod,
      );
      if (result) {
        emit(PatientBookingBookingSuccess());
        return true;
      } else {
        emit(PatientBookingError('Failed to book appointment.'));
        if (currentState is PatientBookingSchedulesSuccess) {
          emit(PatientBookingSchedulesSuccess(currentState.schedules));
        }
        return false;
      }
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.toLowerCase().contains('timeout')) {
        errorMsg = 'السيرفر يأخذ وقتاً طويلاً جداً (Timeout). يرجى مراجعة مطور الباك اند لحل مشكلة إرسال الإيميل.';
      }
      emit(PatientBookingError(errorMsg));
      if (currentState is PatientBookingSchedulesSuccess) {
        emit(PatientBookingSchedulesSuccess(currentState.schedules));
      }
      return false;
    }
  }
}
