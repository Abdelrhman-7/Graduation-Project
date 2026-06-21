
// ignore_for_file: file_names

class ClinicModel {
  final int? id;
  final String name;
  final String address;
  final String phoneNumber;
  final int consultationPrice;
  final String? createdAt;
  final String nots;
  final String appointmentDuration;
  final List<dynamic>? schedules;
  final String? doctorName;
  final String? doctorSpecialty;
  final String? doctorImageUrl;

  ClinicModel({
    this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.consultationPrice,
    this.createdAt,
    required this.appointmentDuration,
    required this.nots,
    this.schedules,
    this.doctorName,
    this.doctorSpecialty,
    this.doctorImageUrl,
  });

  factory ClinicModel.fromJson(Map<String, dynamic> json) {
    // Doctor info can be nested under 'doctor' object or at root level
    final doctorMap = json['doctor'] as Map<String, dynamic>?;
    
    String? rawImageUrl = doctorMap?['imageUrl'] as String? ??
        doctorMap?['profileImageUrl'] as String? ??
        doctorMap?['displayImageUrl'] as String? ??
        json['doctorImageUrl'] as String? ??
        json['imageUrl'] as String? ??
        json['profileImageUrl'] as String? ??
        json['displayImageUrl'] as String?;

    if (rawImageUrl != null && rawImageUrl.isNotEmpty) {
      if (!rawImageUrl.startsWith('http')) {
        rawImageUrl = 'http://medicalsystem111.runasp.net${rawImageUrl.startsWith('/') ? '' : '/'}$rawImageUrl';
      }
    }

    return ClinicModel(
      id: json['id'] is int ? json['id'] as int? : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name'] as String? ?? json['fullName'] as String? ?? 'Clinic/Doctor',
      address: json['address'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      consultationPrice: (json['consultationPrice'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] as String?,
      appointmentDuration: json['appointmentDuration'] as String? ?? '30 mins',
      nots: json['nots'] as String? ?? json['aboutMe'] as String? ?? '',
      schedules: json['clinicSchedules'] as List<dynamic>? ??
          json['schedules'] as List<dynamic>? ??
          json['doctorSchedules'] as List<dynamic>? ??
          json['ClinicSchedules'] as List<dynamic>?,
      doctorName: doctorMap?['fullName'] as String? ??
          doctorMap?['name'] as String? ??
          json['doctorName'] as String? ??
          json['doctorFullName'] as String? ??
          json['fullName'] as String?,
      doctorSpecialty: doctorMap?['specialty'] as String? ??
          doctorMap?['department'] as String? ??
          doctorMap?['departmentName'] as String? ??
          json['doctorSpecialty'] as String? ??
          json['specialty'] as String? ??
          json['department'] as String? ??
          json['departmentName'] as String?,
      doctorImageUrl: rawImageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Address': address,
      'PhoneNumber': phoneNumber,
      'ConsultationPrice': consultationPrice,
      'AppointmentDuration': appointmentDuration,
      'Nots': nots,
      if (schedules != null) 'schedules': schedules,
    };
  }
}
