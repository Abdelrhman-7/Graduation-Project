import 'package:flutter/foundation.dart';

@immutable
abstract class AddClinicState {}

class AddClinicInitial extends AddClinicState {}

class AddClinicLoading extends AddClinicState {}

class AddClinicSuccess extends AddClinicState {}

class AddClinicError extends AddClinicState {
  final String message;
  AddClinicError(this.message);
}
