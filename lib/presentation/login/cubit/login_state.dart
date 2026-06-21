import '../../../data/models/Auth/login_model.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final LoginResponse response;
  LoginSuccess(this.response);
}

class LoginError extends LoginState {
  final String message;
  LoginError(this.message);
}

class LoginPasswordVisibilityChanged extends LoginState {}
