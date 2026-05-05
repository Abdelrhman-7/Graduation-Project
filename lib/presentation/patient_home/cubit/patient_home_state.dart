/*import 'package:flutter/foundation.dart';

@immutable
abstract class PatientHomeState {}

class PatientHomeInitial extends PatientHomeState {}

class PatientHomeLoading extends PatientHomeState {}

class PatientHomeSuccess extends PatientHomeState {
  final String userName;
  final Map<String, dynamic> nextAppointment;
  final List<Map<String, dynamic>> medications;
  final String heartRate;
  final String bloodType;

  PatientHomeSuccess({
    required this.userName,
    required this.nextAppointment,
    required this.medications,
    required this.heartRate,
    required this.bloodType,
  });
}

class PatientHomeError extends PatientHomeState {
  final String message;
  PatientHomeError(this.message);
}
*/