import 'package:flutter/foundation.dart';

@immutable
abstract class DoctorHomeState {}

class DoctorHomeInitial extends DoctorHomeState {}

class DoctorHomeLoading extends DoctorHomeState {}

class DoctorHomeSuccess extends DoctorHomeState {
  final String doctorName;
  final String? imageUrl;
  final String specialty;
  final int patientsToday;
  final Map<String, dynamic> upNextAppointment;
  final List<Map<String, dynamic>> patientRequests;
  final List<Map<String, dynamic>> todaySchedule;

  DoctorHomeSuccess({
    required this.doctorName,
    this.imageUrl,
    required this.specialty,
    required this.patientsToday,
    required this.upNextAppointment,
    required this.patientRequests,
    required this.todaySchedule,
  });
}

class DoctorHomeError extends DoctorHomeState {
  final String message;
  DoctorHomeError(this.message);
}
