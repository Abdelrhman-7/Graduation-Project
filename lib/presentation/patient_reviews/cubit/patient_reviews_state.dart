import '../../../data/models/schudule/doctorModel.dart';

abstract class PatientReviewsState {}

class PatientReviewsInitial extends PatientReviewsState {}

class PatientReviewsLoading extends PatientReviewsState {}

class PatientReviewsSuccess extends PatientReviewsState {
  final List<DoctorModel> doctors;
  PatientReviewsSuccess(this.doctors);
}

class PatientReviewsError extends PatientReviewsState {
  final String message;
  PatientReviewsError(this.message);
}
