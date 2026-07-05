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

class ManageDoctorsOperationLoading extends ManageDoctorsState {}
class ManageDoctorsOperationSuccess extends ManageDoctorsState {
  final String message;
  ManageDoctorsOperationSuccess(this.message);
}
class ManageDoctorsOperationError extends ManageDoctorsState {
  final String message;
  ManageDoctorsOperationError(this.message);
}

class ManageDoctorsDoctorDetailsLoaded extends ManageDoctorsState {
  final Map<String, dynamic> doctor;
  ManageDoctorsDoctorDetailsLoaded(this.doctor);
}
