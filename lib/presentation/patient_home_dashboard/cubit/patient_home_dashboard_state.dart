import 'package:flutter/foundation.dart';

@immutable
abstract class PatientHomeDashboardState {}

class PatientHomeDashboardInitial extends PatientHomeDashboardState {}

class PatientHomeDashboardLoading extends PatientHomeDashboardState {}

class PatientHomeDashboardSuccess extends PatientHomeDashboardState {
  final String userName;
  final String? imageUrl;
  final List<dynamic> medications;
  final int unreadNotifications;
  final dynamic nextAppointment;
  final String heartRate;
  final String bloodPressure;

  PatientHomeDashboardSuccess({
    required this.userName,
    this.imageUrl,
    required this.medications,
    this.unreadNotifications = 0,
    this.nextAppointment,
    this.heartRate = '72',
    this.bloodPressure = '120/80',
  });
}

class PatientHomeDashboardError extends PatientHomeDashboardState {
  final String message;
  PatientHomeDashboardError(this.message);
}
