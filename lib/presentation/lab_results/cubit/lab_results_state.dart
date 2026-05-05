import 'package:flutter/foundation.dart';

@immutable
abstract class LabResultsState {}

class LabResultsInitial extends LabResultsState {}

class LabResultsLoading extends LabResultsState {}

class LabResultsSuccess extends LabResultsState {
  final List<dynamic> reports; // Placeholder for actual report model
  final List<dynamic> detailedResults;
  
  LabResultsSuccess({required this.reports, required this.detailedResults});
}

class LabResultsError extends LabResultsState {
  final String message;
  LabResultsError(this.message);
}
