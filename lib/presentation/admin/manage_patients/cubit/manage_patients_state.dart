abstract class ManagePatientsState {}

class ManagePatientsInitial extends ManagePatientsState {}
class ManagePatientsLoading extends ManagePatientsState {}
class ManagePatientsLoaded extends ManagePatientsState {
  final List<dynamic> patients;
  ManagePatientsLoaded(this.patients);
}
class ManagePatientsError extends ManagePatientsState {
  final String message;
  ManagePatientsError(this.message);
}

class ManagePatientsOperationLoading extends ManagePatientsState {}
class ManagePatientsOperationSuccess extends ManagePatientsState {
  final String message;
  ManagePatientsOperationSuccess(this.message);
}
class ManagePatientsOperationError extends ManagePatientsState {
  final String message;
  ManagePatientsOperationError(this.message);
}

class ManagePatientsPatientDetailsLoaded extends ManagePatientsState {
  final Map<String, dynamic> patient;
  ManagePatientsPatientDetailsLoaded(this.patient);
}
