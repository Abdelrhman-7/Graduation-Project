import 'package:equatable/equatable.dart';

abstract class PatientAppointmentDetailsState extends Equatable {
  const PatientAppointmentDetailsState();

  @override
  List<Object?> get props => [];
}

class PatientAppointmentDetailsInitial extends PatientAppointmentDetailsState {}

class PatientAppointmentDetailsLoading extends PatientAppointmentDetailsState {}

class PatientAppointmentDetailsLoaded extends PatientAppointmentDetailsState {
  final Map<String, dynamic> details;

  const PatientAppointmentDetailsLoaded({required this.details});

  @override
  List<Object?> get props => [details];
}

class PatientAppointmentDetailsError extends PatientAppointmentDetailsState {
  final String message;

  const PatientAppointmentDetailsError({required this.message});

  @override
  List<Object?> get props => [message];
}
