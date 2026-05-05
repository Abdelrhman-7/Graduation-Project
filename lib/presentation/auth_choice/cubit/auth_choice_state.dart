part of 'auth_choice_cubit.dart';

abstract class AuthChoiceState {}

class AuthChoiceInitial extends AuthChoiceState {}

class AuthChoiceLoading extends AuthChoiceState {}

class AuthChoiceSuccess extends AuthChoiceState {
  final String role;
  AuthChoiceSuccess(this.role);
}

class AuthChoiceError extends AuthChoiceState {
  final String message;
  AuthChoiceError(this.message);
}
