import 'package:flutter/foundation.dart';

@immutable
abstract class PatientProfileState {}

class PatientProfileInitial extends PatientProfileState {}

class PatientProfileLoading extends PatientProfileState {}

class PatientProfileSuccess extends PatientProfileState {
  final String name;
  final String? imageUrl;
  final String patientId;
  final String age;
  final String bloodType;
  final String dateOfBirth;
  final String medicalHistory;
  final String allergies;
  final String email;
  final String phone;
  final String address;
  final String gender;

  PatientProfileSuccess({
    required this.name,
    this.imageUrl,
    required this.patientId,
    required this.age,
    required this.bloodType,
    required this.dateOfBirth,
    required this.medicalHistory,
    required this.allergies,
    this.email = '',
    this.phone = '',
    this.address = '',
    this.gender = '',
  });
}

class PatientProfileError extends PatientProfileState {
  final String message;
  PatientProfileError(this.message);
}

class LogoutSuccess extends PatientProfileState {}

class PatientProfileEditSuccess extends PatientProfileState {}

class PatientProfileImageDeleted extends PatientProfileState {}
