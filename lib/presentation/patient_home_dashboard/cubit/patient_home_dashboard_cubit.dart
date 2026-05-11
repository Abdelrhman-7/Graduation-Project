import 'package:flutter_bloc/flutter_bloc.dart';
import 'patient_home_dashboard_state.dart';

class PatientHomeDashboardCubit extends Cubit<PatientHomeDashboardState> {
  PatientHomeDashboardCubit() : super(PatientHomeDashboardInitial());

  void getDashboardData() async {
    emit(PatientHomeDashboardLoading());
    try {
      // Mocking API call
      await Future.delayed(const Duration(milliseconds: 300));
      emit(PatientHomeDashboardSuccess(
        userName: 'Alex',
        medications: [
          {'title': 'Amoxicillin', 'subtitle': '500mg • 1 pill/day', 'badge': 'Active'},
          {'title': 'Lisinopril', 'subtitle': '10mg • 1 pill/day', 'badge': 'Refill'},
        ],
      ));
    } catch (e) {
      emit(PatientHomeDashboardError(e.toString()));
    }
  }
}
