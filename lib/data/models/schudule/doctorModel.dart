class DoctorModel {
  final int id;
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final String? gender;
  final int? age;
  final String? aboutMe;
  final String? imageUrl;
  final String? departmentName;
  final String? departmentDescription;
  final double? rating;

  DoctorModel({
    required this.id,
    required this.fullName,
    this.email,
    this.phoneNumber,
    this.gender,
    this.age,
    this.aboutMe,
    this.imageUrl,
    this.departmentName,
    this.departmentDescription,
    this.rating,
  });

  static String? _readDepartmentName(dynamic department) {
    if (department is String) return department;
    if (department is Map) {
      return department['name'] as String? ??
          department['Name'] as String? ??
          department['departmentName'] as String?;
    }
    return null;
  }

  static String? _readDepartmentDescription(dynamic department) {
    if (department is String) return department;
    if (department is Map) {
      return department['description'] as String? ??
          department['Description'] as String?;
    }
    return null;
  }

  static int _parseId(Map<String, dynamic> json) {
    for (final key in ['doctorId', 'DoctorId', 'id', 'Id']) {
      final value = json[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return 0;
  }

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    String? rawImageUrl = json['imageUrl'] as String? ??
        json['ImageUrl'] as String? ??
        json['profileImageUrl'] as String? ??
        json['ProfileImageUrl'] as String? ??
        json['displayImageUrl'] as String? ??
        json['DisplayImageUrl'] as String?;

    if (rawImageUrl != null && rawImageUrl.isNotEmpty) {
      if (!rawImageUrl.startsWith('http')) {
        rawImageUrl =
            'http://clinicbook.runasp.net${rawImageUrl.startsWith('/') ? '' : '/'}$rawImageUrl';
      }
    }

    final departmentField = json['department'] ?? json['Department'];

    return DoctorModel(
      id: _parseId(json),
      fullName: json['fullName'] as String? ??
          json['FullName'] as String? ??
          json['name'] as String? ??
          json['Name'] as String? ??
          json['userName'] as String? ??
          json['UserName'] as String? ??
          'Doctor',
      email: json['email'] as String? ?? json['Email'] as String?,
      phoneNumber:
          json['phoneNumber'] as String? ?? json['PhoneNumber'] as String?,
      gender: json['gender'] as String? ?? json['Gender'] as String?,
      age: json['age'] is int
          ? json['age'] as int?
          : int.tryParse(json['age']?.toString() ?? '') ??
              int.tryParse(json['Age']?.toString() ?? ''),
      aboutMe: json['aboutMe'] as String? ??
          json['AboutMe'] as String? ??
          json['nots'] as String?,
      imageUrl: rawImageUrl,
      departmentName: json['departmentName'] as String? ??
          json['DepartmentName'] as String? ??
          _readDepartmentName(departmentField),
      departmentDescription: json['departmentDescription'] as String? ??
          json['DepartmentDescription'] as String? ??
          _readDepartmentDescription(departmentField),
    );
  }
}
