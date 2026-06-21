abstract class ManageDoctorsState {}

class ManageDoctorsInitial extends ManageDoctorsState {}
class ManageDoctorsLoading extends ManageDoctorsState {}
class ManageDoctorsLoaded extends ManageDoctorsState {
  final List<dynamic> doctors;
  ManageDoctorsLoaded(this.doctors);
}
class ManageDoctorsError extends ManageDoctorsState {
  final String message;
  ManageDoctorsError(this.message);
}
