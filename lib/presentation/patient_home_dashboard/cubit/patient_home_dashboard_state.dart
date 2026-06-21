import 'package:flutter/foundation.dart';

@immutable
abstract class PatientHomeDashboardState {}

class PatientHomeDashboardInitial extends PatientHomeDashboardState {}

class PatientHomeDashboardLoading extends PatientHomeDashboardState {}

class PatientHomeDashboardSuccess extends PatientHomeDashboardState {
  final String userName;
  final String? imageUrl;
  final List<dynamic> medications;

  PatientHomeDashboardSuccess({
    required this.userName,
    this.imageUrl,
    required this.medications,
  });
}

class PatientHomeDashboardError extends PatientHomeDashboardState {
  final String message;
  PatientHomeDashboardError(this.message);
}
