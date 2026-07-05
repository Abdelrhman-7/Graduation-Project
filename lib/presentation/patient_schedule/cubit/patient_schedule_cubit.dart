import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduationproject/data/repository/repository.dart';
import 'patient_schedule_state.dart';
export 'patient_schedule_state.dart';

class PatientScheduleCubit extends Cubit<PatientScheduleState> {
  final Repository repository;

  PatientScheduleCubit(this.repository) : super(PatientScheduleInitial());

  Future<void> fetchAppointments() async {
    emit(PatientScheduleLoading());
    try {
      final appointments = await repository.getPatientAppointments();
      emit(PatientScheduleSuccess(appointments));
    } catch (e) {
      emit(PatientScheduleError(e.toString()));
    }
  }

  Future<void> cancelBooking(int bookingId) async {
    final currentState = state;
    if (currentState is! PatientScheduleSuccess) return;

    emit(PatientScheduleProcessing(currentState.appointments, bookingId));
    try {
      await repository.cancelPatientBooking(bookingId);
      final updated = await repository.getPatientAppointments();
      emit(PatientScheduleSuccess(updated));
    } catch (e) {
      emit(PatientScheduleSuccess(currentState.appointments));
      emit(PatientScheduleProcessError(e.toString(), currentState.appointments));
    }
  }

  Future<void> editAppointment(int bookingId, Map<String, dynamic> data) async {
    final currentState = state;
    if (currentState is! PatientScheduleSuccess) return;

    emit(PatientScheduleProcessing(currentState.appointments, bookingId));
    try {
      await repository.editPatientAppointment(bookingId, data);
      final updated = await repository.getPatientAppointments();
      emit(PatientScheduleSuccess(updated));
    } catch (e) {
      emit(PatientScheduleSuccess(currentState.appointments));
      emit(PatientScheduleProcessError(e.toString(), currentState.appointments));
    }
  }

  Future<void> deleteAppointmentImage(int bookingId, int imageId) async {
    final currentState = state;
    if (currentState is! PatientScheduleSuccess) return;

    emit(PatientScheduleProcessing(currentState.appointments, bookingId));
    try {
      await repository.apiManager.deleteAppointmentPatientImage(imageId);
      final updated = await repository.getPatientAppointments();
      emit(PatientScheduleSuccess(updated));
    } catch (e) {
      emit(PatientScheduleSuccess(currentState.appointments));
      emit(PatientScheduleProcessError(e.toString(), currentState.appointments));
    }
  }
}
