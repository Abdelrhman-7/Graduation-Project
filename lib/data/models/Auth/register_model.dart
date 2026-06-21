class RegisterRequest {
  // Common
  final String fullName;
  final String email;
  final String password;
  final String confirmPassword;
  final String phoneNumber;
  final String address;
  final String gender;
  final String dateOfBirth;

  // User only
  final String? userName;

  // Doctor only
  final int? departmentId;
  final String? aboutMe;
  final String? imageFile;

  RegisterRequest({
    required this.fullName,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.phoneNumber,
    required this.address,
    required this.gender,
    required this.dateOfBirth,

    this.userName,

    this.departmentId,
    this.aboutMe,
    this.imageFile,
  });

  Map<String, dynamic> toMap({required bool isDoctor}) {
    final map = <String, dynamic>{
      // Common
      'FullName': fullName,
      'Email': email,
      'Password': password,
      'ConfirmPassword': confirmPassword,
      'PhoneNumber': phoneNumber,
      'Address': address,
      'Gender': gender,
      'DateOfBirth': dateOfBirth,
    };

    // USER
    if (!isDoctor && userName != null) {
      map['UserName'] = userName;
    }

    // DOCTOR
    if (isDoctor) {
      map['DepartmentId'] = departmentId;
      map['AboutMe'] = aboutMe;
    }

    return map;
  }
}

class RegisterResponse {
  final bool? status;
  final String? message;

  RegisterResponse({this.status, this.message});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      status: json['status'] as bool? ?? (json['userId'] != null),

      message: json['message']?.toString() ?? json['title']?.toString(),
    );
  }
}
