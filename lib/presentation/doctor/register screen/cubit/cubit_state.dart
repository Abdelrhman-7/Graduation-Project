part of 'registergoctor_cubit.dart';

sealed class DoctorRegisterState {}

final class DoctorRegisterInitial extends DoctorRegisterState {}

final class DoctorRegisterLoading extends DoctorRegisterState {}

final class DoctorRegisterSuccess extends DoctorRegisterState {
  final String message;
  DoctorRegisterSuccess({required this.message});
}

final class DoctorRegisterError extends DoctorRegisterState {
  final String errorMessage;
  DoctorRegisterError({required this.errorMessage});
}
