import 'package:flutter/foundation.dart';

@immutable
abstract class LabResultsState {}

class LabResultsInitial extends LabResultsState {}

class LabResultsSubmitLoading extends LabResultsState {}

class LabResultsSubmitSuccess extends LabResultsState {}

class LabResultsSubmitError extends LabResultsState {
  final String message;
  LabResultsSubmitError(this.message);
}
