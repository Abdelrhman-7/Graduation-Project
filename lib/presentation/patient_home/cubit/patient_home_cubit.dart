/*import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/api/api_manager.dart';
import 'patient_home_state.dart';

class PatientHomeCubit extends Cubit<PatientHomeState> {
  // ignore: unused_field
  final ApiManager _apiService;

  PatientHomeCubit(this._apiService) : super(PatientHomeInitial());

  void getHomeData() async {
    emit(PatientHomeLoading());

    // Simulate API call for now
    await Future.delayed(const Duration(seconds: 1));

    emit(
      PatientHomeSuccess(
        userName: 'Abdelrhman',
        heartRate: '72 bpm',
        bloodType: 'O+',
        nextAppointment: {
          'doctorName': 'Dr. Sarah Ahmed',
          'specialty': 'Cardiologist',
          'dateTime': 'Tue, Oct 24 • 10:00 AM',
        },
        medications: [
          {
            'name': 'Panadol Extra',
            'dosage': '500mg • After Food',
            'time': '08:00 AM',
            'type': 'pill',
          },
          {
            'name': 'Vitamin C',
            'dosage': '1000mg • Once Daily',
            'time': '10:00 AM',
            'type': 'liquid',
          },
        ],
      ),
    );
  }
}
*/