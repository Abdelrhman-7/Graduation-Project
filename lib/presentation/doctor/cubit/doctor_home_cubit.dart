import 'package:flutter_bloc/flutter_bloc.dart';
import 'doctor_home_state.dart';

class DoctorHomeCubit extends Cubit<DoctorHomeState> {
  DoctorHomeCubit() : super(DoctorHomeInitial());

  void getDoctorHomeData() async {
    emit(DoctorHomeLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      emit(DoctorHomeSuccess(
        doctorName: 'Dr. Sarah Wilson',
        specialty: 'Cardiologist',
        patientsToday: 12,
        upNextAppointment: {
          'patientName': 'Mark Thompson',
          'time': '10:30 AM',
          'type': 'Video Consultation',
          'status': 'In 5 min',
        },
        patientRequests: [
          {
            'patientName': 'Emily Davis',
            'type': 'Refill Request',
            'details': 'Lisinopril 10mg',
            'time': '2h ago',
          },
          {
            'patientName': 'James Miller',
            'type': 'Lab Result Review',
            'details': 'CBC & Lipid Panel',
            'time': '4h ago',
          }
        ],
        todaySchedule: [
          {'time': '09:00 AM', 'title': 'Routine Checkup', 'patient': 'John Doe'},
          {'time': '10:00 AM', 'title': 'Follow-up', 'patient': 'Jane Smith'},
          {'time': '12:00 PM', 'title': 'Lunch Break', 'isBreak': true},
          {'time': '01:30 PM', 'title': 'Post-surgery Follow-up', 'patient': 'Robert Brown'},
        ],
      ));
    } catch (e) {
      emit(DoctorHomeError(e.toString()));
    }
  }
}
