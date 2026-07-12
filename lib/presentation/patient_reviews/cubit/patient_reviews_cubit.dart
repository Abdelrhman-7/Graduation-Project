import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduationproject/data/repository/shared_pref_controller.dart';
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

      final Map<int, DoctorModel> uniqueDoctors = {};

      try {
        final docs = await apiManager.getPatientDoctors(currentPage: 1);
        for (var doc in docs) {
          uniqueDoctors[doc.id] = doc;
        }
      } catch (e) {
        print('Error fetching all doctors: $e');
      }

      try {
        final activeAppointments = await apiManager.getPatientAllAppointments(
          currentPage: 1,
        );
        final historyAppointments = await apiManager
            .getPatientHistoryAppointments(page: 1);
        final responseList = [...activeAppointments, ...historyAppointments];

        for (var json in responseList) {
          if (json is Map<String, dynamic>) {
            final booking = BookingModel.fromJson(json);
            final doctorId = booking.doctorId;
            if (doctorId != null &&
                doctorId > 0 &&
                !uniqueDoctors.containsKey(doctorId)) {
              uniqueDoctors[doctorId] = DoctorModel(
                id: doctorId,
                fullName: booking.doctorName ?? 'Unknown Doctor',
                email: '',
                phoneNumber: '',
                gender: '',
                departmentName: booking.clinicName ?? '',
                aboutMe: '',
                imageUrl: booking.doctorImageUrl,
              );
            }
          }
        }
      } catch (e) {
        print('Error fetching appointments: $e');
      }

      // Get current patient ID for filtering their specific comment
      final profile = await apiManager.getPatientProfile();
      final prefs = SharedPrefController();
      final currentPatientId =
          profile?['id']?.toString() ?? await prefs.getEmail() ?? '';

      final List<DoctorModel> ratedDoctors = [];

      for (var doctor in uniqueDoctors.values) {
        try {
          final reviews = await apiManager.getPatientDoctorReviews(doctor.id);

          double totalRating = 0;
          int reviewCount = 0;
          String userComment = '';

          if (reviews.isNotEmpty) {
            for (var review in reviews) {
              final rating = (review['rating'] as num?)?.toDouble() ?? 0.0;
              if (rating > 0) {
                totalRating += rating;
                reviewCount++;
              }

              // Check if this review belongs to the current patient
              final rPatientId =
                  review['patientId']?.toString() ??
                  review['PatientId']?.toString() ??
                  review['userId']?.toString() ??
                  review['UserId']?.toString();
              if (rPatientId != null &&
                  rPatientId.toString() == currentPatientId) {
                userComment = (review['comment'] ?? '').toString();
              }
            }
          }

          final averageRating = reviewCount > 0
              ? (totalRating / reviewCount)
              : 0.0;

          ratedDoctors.add(
            DoctorModel(
              id: doctor.id,
              fullName: doctor.fullName,
              email: doctor.email,
              phoneNumber: doctor.phoneNumber,
              gender: doctor.gender,
              departmentName: doctor.departmentName,
              aboutMe:
                  userComment, // Storing only user's comment (or empty) for the view
              rating: averageRating,
              imageUrl: doctor.imageUrl,
            ),
          );
        } catch (e) {
          print('Error fetching reviews for doctor ${doctor.id}: $e');
        }
      }

      emit(PatientReviewsSuccess(ratedDoctors));
    } catch (e) {
      emit(PatientReviewsError('Failed to load doctors: $e'));
    }
  }
}
