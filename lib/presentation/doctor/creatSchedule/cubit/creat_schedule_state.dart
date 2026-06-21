import 'package:equatable/equatable.dart';
import 'package:graduationproject/data/models/schudule/cliniceSchedual.dart';

abstract class CreateScheduleState extends Equatable {
  const CreateScheduleState();

  @override
  List<Object?> get props => [];
}

class CreateScheduleInitial extends CreateScheduleState {}

class CreateScheduleLoading extends CreateScheduleState {}

// حالة نجاح جلب العيادات
class CreateScheduleClinicsLoaded extends CreateScheduleState {
  final List<ClinicModel> clinics;
  const CreateScheduleClinicsLoaded(this.clinics);

  @override
  List<Object?> get props => [clinics];
}

class CreateScheduleAddSuccess extends CreateScheduleState {}

class CreateScheduleDeleteSuccess extends CreateScheduleState {}

class CreateScheduleEditSuccess extends CreateScheduleState {}

// حالة عرض كل المواعيد
class CreateScheduleAllLoaded extends CreateScheduleState {
  final List<dynamic> schedules;
  final List<ClinicModel> clinics;
  const CreateScheduleAllLoaded({required this.schedules, required this.clinics});

  @override
  List<Object?> get props => [schedules, clinics];
}

class CreateScheduleError extends CreateScheduleState {
  final String message;
  const CreateScheduleError(this.message);

  @override
  List<Object?> get props => [message];
}
