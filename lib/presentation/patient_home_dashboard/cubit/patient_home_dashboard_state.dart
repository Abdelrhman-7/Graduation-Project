import 'package:flutter/foundation.dart';

@immutable
abstract class PatientHomeDashboardState {}

class PatientHomeDashboardInitial extends PatientHomeDashboardState {}

class PatientHomeDashboardLoading extends PatientHomeDashboardState {}

class PatientHomeDashboardSuccess extends PatientHomeDashboardState {
  final String userName;
  final List<dynamic> medications;
  // Add other dashboard data here

  PatientHomeDashboardSuccess({
    required this.userName,
    required this.medications,
  });
}

class PatientHomeDashboardError extends PatientHomeDashboardState {
  final String message;
  PatientHomeDashboardError(this.message);
}
