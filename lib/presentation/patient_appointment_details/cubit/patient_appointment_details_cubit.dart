import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repository/repository.dart';
import 'patient_appointment_details_state.dart';

class PatientAppointmentDetailsCubit extends Cubit<PatientAppointmentDetailsState> {
  final Repository repository;

  PatientAppointmentDetailsCubit({required this.repository}) : super(PatientAppointmentDetailsInitial());

  Future<void> getDetails(int bookingId, {Map<String, dynamic>? initialData}) async {
    // Show initial data immediately while fetching from API
    if (initialData != null && initialData.isNotEmpty) {
      emit(PatientAppointmentDetailsLoaded(details: initialData));
    } else {
      emit(PatientAppointmentDetailsLoading());
    }
    try {
      final details = await repository.getPatientAppointment(bookingId);
      if (details != null && !details.containsKey('error')) {
        // Merge: prefer API data but keep local fields the API might be missing
        final merged = <String, dynamic>{};
        if (initialData != null) merged.addAll(initialData);
        merged.addAll(details);
        // Keep local date/dayOfWeek if API didn't return them
        if ((merged['dayOfWeek'] == null || merged['dayOfWeek'].toString().isEmpty) &&
            initialData != null) {
          merged['dayOfWeek'] ??= initialData['dayOfWeek'];
        }
        if ((merged['bookingDate'] == null || merged['bookingDate'].toString().isEmpty) &&
            initialData != null) {
          merged['bookingDate'] ??= initialData['bookingDate'];
        }
        if ((merged['time'] == null || merged['time'].toString().isEmpty) &&
            initialData != null) {
          merged['time'] ??= initialData['timeSlot'] ?? initialData['time'];
        }
        
        // Inject doctor image
        try {
          final doctors = await repository.getPatientDoctors();
          final docIdStr = merged['doctorId'] ?? merged['doctor']?['id'];
          final docId = docIdStr != null ? (docIdStr is int ? docIdStr : int.tryParse(docIdStr.toString()) ?? 0) : 0;
          if (docId != 0) {
            final doc = doctors.firstWhere((d) => d.id == docId);
            if (doc.imageUrl != null && doc.imageUrl!.isNotEmpty) {
              merged['doctorImageUrl'] = doc.imageUrl;
            }
          }
        } catch (_) {}

        emit(PatientAppointmentDetailsLoaded(details: merged));
      } else if (initialData != null) {
        // Keep showing initial data on API error
        emit(PatientAppointmentDetailsLoaded(details: initialData));
      } else {
        emit(PatientAppointmentDetailsError(
            message: details?.containsKey('error') == true
                ? details!['error'].toString()
                : 'Failed to load details for ID $bookingId.'));
      }
    } catch (e) {
      if (initialData != null) {
        emit(PatientAppointmentDetailsLoaded(details: initialData));
      } else {
        emit(PatientAppointmentDetailsError(message: 'An error occurred: $e'));
      }
    }
  }
}
