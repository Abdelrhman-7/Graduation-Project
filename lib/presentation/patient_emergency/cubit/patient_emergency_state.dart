abstract class PatientEmergencyState {}

class PatientEmergencyInitial extends PatientEmergencyState {}

class PatientEmergencyLoading extends PatientEmergencyState {}

class PatientEmergencySuccess extends PatientEmergencyState {}

class PatientEmergencyError extends PatientEmergencyState {
  final String message;
  PatientEmergencyError(this.message);
}
