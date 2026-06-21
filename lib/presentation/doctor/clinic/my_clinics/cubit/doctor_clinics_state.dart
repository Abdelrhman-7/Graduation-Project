import 'package:graduationproject/data/models/schudule/cliniceSchedual.dart';

abstract class DoctorClinicsState {}

class DoctorClinicsInitial extends DoctorClinicsState {}

class DoctorClinicsLoading extends DoctorClinicsState {}

class DoctorClinicsSuccess extends DoctorClinicsState {
  final List<ClinicModel> clinics;
  DoctorClinicsSuccess({required this.clinics});
}

class DoctorClinicsError extends DoctorClinicsState {
  final String message;
  DoctorClinicsError({required this.message});
}
