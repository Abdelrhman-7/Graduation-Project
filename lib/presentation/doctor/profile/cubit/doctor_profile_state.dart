abstract class DoctorProfileState {}

class DoctorProfileInitial extends DoctorProfileState {}

class DoctorProfileLoading extends DoctorProfileState {}

class DoctorProfileEditSuccess extends DoctorProfileState {}

class DoctorProfileError extends DoctorProfileState {
  final String message;
  DoctorProfileError(this.message);
}

class DoctorProfileLoaded extends DoctorProfileState {
  final Map<String, dynamic> profileData;
  DoctorProfileLoaded(this.profileData);
}

class DoctorProfileImageDeleted extends DoctorProfileState {}

class LogoutSuccess extends DoctorProfileState {}

class DoctorProfilePasswordChangeLoading extends DoctorProfileState {}

class DoctorProfilePasswordChangeSuccess extends DoctorProfileState {}

class DoctorProfilePasswordChangeError extends DoctorProfileState {
  final String message;
  DoctorProfilePasswordChangeError(this.message);
}
