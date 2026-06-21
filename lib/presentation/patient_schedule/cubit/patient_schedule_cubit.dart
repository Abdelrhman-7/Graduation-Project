import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduationproject/data/repository/repository.dart';
import 'patient_schedule_state.dart';

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
}
