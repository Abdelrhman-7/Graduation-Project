abstract class PatientRegistrationState {}

class PatientRegistrationInitial extends PatientRegistrationState {}

class PatientRegistrationUpdated extends PatientRegistrationState {
  final List<String> allergies;
  final List<String> conditions;

  PatientRegistrationUpdated({
    required this.allergies,
    required this.conditions,
  });
}
