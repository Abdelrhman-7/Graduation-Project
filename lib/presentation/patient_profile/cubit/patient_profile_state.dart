import 'package:flutter/foundation.dart';

@immutable
abstract class PatientProfileState {}

class PatientProfileInitial extends PatientProfileState {}

class PatientProfileLoading extends PatientProfileState {}

class PatientProfileSuccess extends PatientProfileState {
  final String name;
  final String patientId;
  final String age;
  final String bloodType;
  final String dateOfBirth;
  final String medicalHistory;
  final String allergies;

  PatientProfileSuccess({
    required this.name,
    required this.patientId,
    required this.age,
    required this.bloodType,
    required this.dateOfBirth,
    required this.medicalHistory,
    required this.allergies,
  });
}

class PatientProfileError extends PatientProfileState {
  final String message;
  PatientProfileError(this.message);
}

class LogoutSuccess extends PatientProfileState {}
