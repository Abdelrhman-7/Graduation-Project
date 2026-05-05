abstract class PatientRegistrationState {}

class PatientRegistrationInitial extends PatientRegistrationState {}

class PatientRegistrationUpdated extends PatientRegistrationState {
  final List<String> allergies;
  final List<String> conditions;

  PatientRegistrationUpdated({required this.allergies, required this.conditions});
}

class PatientRegistrationLoading extends PatientRegistrationState {}

class PatientRegistrationSuccess extends PatientRegistrationState {
  final String? message;
  PatientRegistrationSuccess(this.message);
}

class PatientRegistrationError extends PatientRegistrationState {
  final String message;
  PatientRegistrationError(this.message);
}
