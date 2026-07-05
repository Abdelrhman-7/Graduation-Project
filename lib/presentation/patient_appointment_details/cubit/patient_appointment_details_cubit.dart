import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repository/repository.dart';
import 'patient_appointment_details_state.dart';

class PatientAppointmentDetailsCubit extends Cubit<PatientAppointmentDetailsState> {
  final Repository repository;

  PatientAppointmentDetailsCubit({required this.repository}) : super(PatientAppointmentDetailsInitial());

  Future<void> getDetails(int bookingId) async {
    emit(PatientAppointmentDetailsLoading());
    try {
      final details = await repository.getPatientAppointment(bookingId);
      print('=== APPOINTMENT DETAILS IN CUBIT ===');
      print(details);
      
      if (details != null) {
        if (details.containsKey('error')) {
          emit(PatientAppointmentDetailsError(message: 'Debug [ID: $bookingId]: ${details['error']}'));
        } else {
          emit(PatientAppointmentDetailsLoaded(details: details));
        }
      } else {
        emit(PatientAppointmentDetailsError(message: 'Failed to load details for ID $bookingId.'));
      }
    } catch (e) {
      emit(PatientAppointmentDetailsError(message: 'An error occurred: $e'));
    }
  }
}
