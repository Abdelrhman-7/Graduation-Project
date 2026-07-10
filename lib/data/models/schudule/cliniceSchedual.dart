
// ignore_for_file: file_names

class ClinicModel {
  final int? id;
  final String name;
  final String address;
  final String phoneNumber;
  final int consultationPrice;
  final String? createdAt;
  String nots;
  String appointmentDuration;
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

  static int? _parseClinicId(Map<String, dynamic> json) {
    for (final key in ['id', 'Id', 'clinicId', 'ClinicId']) {
      final value = json[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  factory ClinicModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? doctorMap;
    String? doctorNameFromField;

    final doctorField = json['doctor'] ?? json['Doctor'];
    if (doctorField is Map<String, dynamic>) {
      doctorMap = doctorField;
    } else if (doctorField is Map) {
      doctorMap = Map<String, dynamic>.from(doctorField);
    } else if (doctorField is String && doctorField.isNotEmpty) {
      doctorNameFromField = doctorField;
    }

    String? readDepartmentName(dynamic department) {
      if (department is String) return department;
      if (department is Map) {
        return department['name'] as String? ??
            department['Name'] as String? ??
            department['departmentName'] as String?;
      }
      return null;
    }

    String? rawImageUrl = doctorMap?['imageUrl'] as String? ??
        doctorMap?['profileImageUrl'] as String? ??
        doctorMap?['displayImageUrl'] as String? ??
        json['doctorImageUrl'] as String? ??
        json['imageUrl'] as String? ??
        json['profileImageUrl'] as String? ??
        json['displayImageUrl'] as String?;

    if (rawImageUrl != null && rawImageUrl.isNotEmpty) {
      if (!rawImageUrl.startsWith('http')) {
        rawImageUrl =
            'http://mediconnect.somee.com${rawImageUrl.startsWith('/') ? '' : '/'}$rawImageUrl';
      }
    }

    return ClinicModel(
      id: _parseClinicId(json),
      name: json['name'] as String? ??
          json['Name'] as String? ??
          json['fullName'] as String? ??
          'Clinic',
      address: json['address'] as String? ?? json['Address'] as String? ?? '',
      phoneNumber:
          json['phoneNumber'] as String? ?? json['PhoneNumber'] as String? ?? '',
      consultationPrice: (json['consultationPrice'] as num?)?.toInt() ??
          (json['ConsultationPrice'] as num?)?.toInt() ??
          (json['price'] as num?)?.toInt() ??
          (json['Price'] as num?)?.toInt() ??
          (json['fee'] as num?)?.toInt() ??
          (json['Fee'] as num?)?.toInt() ??
          (json['clinicPrice'] as num?)?.toInt() ??
          (json['ClinicPrice'] as num?)?.toInt() ??
          (json['consultationFee'] as num?)?.toInt() ??
          (json['ConsultationFee'] as num?)?.toInt() ??
          0,
      createdAt: json['createdAt'] as String? ?? json['CreatedAt'] as String?,
      appointmentDuration: json['appointmentDuration']?.toString() ??
          json['AppointmentDuration']?.toString() ??
          '30 mins',
      nots: json['nots'] as String? ??
          json['Nots'] as String? ??
          json['aboutMe'] as String? ??
          '',
      schedules: json['clinicSchedules'] as List<dynamic>? ??
          json['schedules'] as List<dynamic>? ??
          json['doctorSchedules'] as List<dynamic>? ??
          json['ClinicSchedules'] as List<dynamic>?,
      doctorName: doctorNameFromField ??
          doctorMap?['fullName'] as String? ??
          doctorMap?['name'] as String? ??
          json['doctorName'] as String? ??
          json['doctorFullName'] as String? ??
          json['fullName'] as String?,
      doctorSpecialty: doctorMap?['specialty'] as String? ??
          readDepartmentName(doctorMap?['department']) ??
          doctorMap?['departmentName'] as String? ??
          json['doctorSpecialty'] as String? ??
          json['specialty'] as String? ??
          readDepartmentName(json['department']) ??
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
