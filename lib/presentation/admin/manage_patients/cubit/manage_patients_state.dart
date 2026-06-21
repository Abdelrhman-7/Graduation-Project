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
