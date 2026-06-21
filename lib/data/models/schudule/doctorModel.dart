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
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    String? rawImageUrl = json['imageUrl'] as String? ??
        json['profileImageUrl'] as String? ??
        json['displayImageUrl'] as String?;

    if (rawImageUrl != null && rawImageUrl.isNotEmpty) {
      if (!rawImageUrl.startsWith('http')) {
        rawImageUrl =
            'http://medicalsystem111.runasp.net${rawImageUrl.startsWith('/') ? '' : '/'}$rawImageUrl';
      }
    }

    return DoctorModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      fullName: json['fullName'] as String? ?? json['name'] as String? ?? 'Doctor',
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      gender: json['gender'] as String?,
      age: json['age'] is int
          ? json['age'] as int?
          : int.tryParse(json['age']?.toString() ?? ''),
      aboutMe: json['aboutMe'] as String? ?? json['nots'] as String?,
      imageUrl: rawImageUrl,
      departmentName: json['departmentName'] as String? ??
          json['department'] as String? ??
          (json['department'] is Map ? json['department']['name'] as String? : null),
      departmentDescription: json['departmentDescription'] as String? ??
          (json['department'] is Map ? json['department']['description'] as String? : null),
    );
  }
}
