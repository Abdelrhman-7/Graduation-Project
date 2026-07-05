import 'package:flutter/foundation.dart';

@immutable
abstract class DoctorReviewsState {}

class DoctorReviewsInitial extends DoctorReviewsState {}
class DoctorReviewsLoading extends DoctorReviewsState {}
class DoctorReviewsSuccess extends DoctorReviewsState {
  final List<Map<String, dynamic>> reviews;
  DoctorReviewsSuccess(this.reviews);
}
class DoctorReviewsError extends DoctorReviewsState {
  final String message;
  DoctorReviewsError(this.message);
}
