// ignore_for_file: file_names

class CreateScheduleModel {
  final String? day;
  final String? startTime;
  final String? endTime;
  final int? clinicId;
  final String? appointmentDuration;
  final String? nots;

  CreateScheduleModel({
    this.day,
    this.startTime,
    this.endTime,
    this.clinicId,
    this.appointmentDuration,
    this.nots,
  });

  factory CreateScheduleModel.fromJson(Map<String, dynamic> json) =>
      CreateScheduleModel(
        day: json['day'] as String?,
        startTime: json['startTime'] as String?,
        endTime: json['endTime'] as String?,
        clinicId: json['clinicId'] as int?,
        appointmentDuration: json['appointmentDuration'] as String?,
        nots: json['nots'] as String?,
      );

  Map<String, dynamic> toJson() => {
    if (day != null) 'day': day,
    if (startTime != null) 'startTime': startTime,
    if (endTime != null) 'endTime': endTime,
    if (clinicId != null) 'clinicId': clinicId,
    if (appointmentDuration != null) 'appointmentDuration': appointmentDuration,
    if (nots != null) 'nots': nots,
  };
}

// ignore: camel_case_types
class editClinicModel {
  final String? day;
  final String? startTime;
  final String? endTime;
  final String? clinicId;
  final String? appointmentDuration;
  final String? nots;
  final int? id;

  editClinicModel({
    this.day,
    this.startTime,
    this.endTime,
    this.clinicId,
    this.appointmentDuration,
    this.nots,
    this.id,
  });

  factory editClinicModel.fromJson(Map<String, dynamic> json) =>
      editClinicModel(
        day: json['day'] as String?,
        startTime: json['startTime'] as String?,
        endTime: json['endTime'] as String?,
        clinicId: json['clinicId'] as String?,
        appointmentDuration: json['appointmentDuration'] as String?,
        nots: json['nots'] as String?,
        id: json['id'] as int?,
      );

  Map<String, dynamic> toJson() => {
    if (day != null) 'day': day,
    if (startTime != null) 'startTime': startTime,
    if (endTime != null) 'endTime': endTime,
    if (clinicId != null) 'clinicId': clinicId,
    if (appointmentDuration != null) 'appointmentDuration': appointmentDuration,
    if (nots != null) 'nots': nots,
    if (id != null) 'id': id,
  };
}
