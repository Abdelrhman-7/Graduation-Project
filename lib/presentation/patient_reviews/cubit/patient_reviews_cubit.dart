import 'package:flutter_bloc/flutter_bloc.dart';
import 'patient_reviews_state.dart';
import '../../../../data/api/api_manager.dart';
import '../../../../data/models/schudule/doctorModel.dart';
import '../../../../data/models/booking/booking_model.dart';

class PatientReviewsCubit extends Cubit<PatientReviewsState> {
  PatientReviewsCubit() : super(PatientReviewsInitial());

  Future<void> loadDoctors() async {
    emit(PatientReviewsLoading());
    try {
      final apiManager = await ApiManager.create();
      final responseList = await apiManager.getPatientAllAppointments(currentPage: 1);
      
      final Map<int, DoctorModel> uniqueDoctors = {};
      
      for (var json in responseList) {
        if (json is Map<String, dynamic>) {
          final booking = BookingModel.fromJson(json);
          final doctorId = booking.doctorId;
          if (doctorId != null && doctorId > 0 && !uniqueDoctors.containsKey(doctorId)) {
            uniqueDoctors[doctorId] = DoctorModel(
              id: doctorId,
              fullName: booking.doctorName ?? 'Unknown Doctor',
              email: '',
              phoneNumber: '',
              gender: '',
              departmentName: booking.clinicName ?? '',
              aboutMe: '',
            );
          }
        }
      }

      final List<DoctorModel> ratedDoctors = [];

      for (var doctor in uniqueDoctors.values) {
        final reviews = await apiManager.getPatientDoctorReviews(doctor.id);
        if (reviews.isNotEmpty) {
          final review = reviews.first;
          final rating = (review['rating'] as num?)?.toDouble() ?? 0.0;
          final comment = (review['comment'] ?? '').toString();
          ratedDoctors.add(DoctorModel(
            id: doctor.id,
            fullName: doctor.fullName,
            email: doctor.email,
            phoneNumber: doctor.phoneNumber,
            gender: doctor.gender,
            departmentName: doctor.departmentName,
            aboutMe: comment, // Storing comment in aboutMe for the view
            rating: rating,
          ));
        }
      }

      emit(PatientReviewsSuccess(ratedDoctors));
    } catch (e) {
      emit(PatientReviewsError('Failed to load doctors: $e'));
    }
  }
}
