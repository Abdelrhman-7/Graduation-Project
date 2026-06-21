import 'package:graduationproject/data/models/schudule/cliniceSchedual.dart';
import 'package:graduationproject/data/models/schudule/doctorModel.dart';

abstract class PatientBookingState {}

class PatientBookingInitial extends PatientBookingState {}

class PatientBookingLoading extends PatientBookingState {}

class PatientBookingBooking extends PatientBookingState {}

class PatientBookingSuccess extends PatientBookingState {
  final List<ClinicModel> clinics;
  PatientBookingSuccess(this.clinics);
}

class PatientBookingDoctorsSuccess extends PatientBookingState {
  final List<DoctorModel> doctors;
  PatientBookingDoctorsSuccess(this.doctors);
}

class PatientBookingDoctorDetailsSuccess extends PatientBookingState {
  final DoctorModel doctor;
  PatientBookingDoctorDetailsSuccess(this.doctor);
}

class PatientBookingClinicsSuccess extends PatientBookingState {
  final List<ClinicModel> clinics;
  PatientBookingClinicsSuccess(this.clinics);
}

class PatientBookingSchedulesSuccess extends PatientBookingState {
  final List<dynamic> schedules;
  PatientBookingSchedulesSuccess(this.schedules);
}

class PatientBookingBookingSuccess extends PatientBookingState {}

class PatientBookingError extends PatientBookingState {
  final String message;
  PatientBookingError(this.message);
}
