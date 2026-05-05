class RegisterRequest {
  final String fullName;
  final String userName; // ASP.NET Identity requires UserName
  final String email;
  final String password;
  final String phoneNumber;
  final String address;
  final String gender;
  final String dateOfBirth;
  final dynamic imageFile; // Can be a String path or MultipartFile

  RegisterRequest({
    required this.fullName,
    required this.userName,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.address,
    required this.gender,
    required this.dateOfBirth,
    this.imageFile,
  });

  Map<String, dynamic> toMap() => {
    'FullName': fullName,
    'UserName': userName,
    'Email': email,
    'Password': password,
    'PhoneNumber': phoneNumber,
    'Address': address,
    'Gender': gender,
    'DateOfBirth': dateOfBirth,
    // ImageFile is handled separately in ApiManager for Multipart
  };
}

class RegisterResponse {
  final bool? status;
  final String? message;

  RegisterResponse({this.status, this.message});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      RegisterResponse(
        status: json['status'] as bool? ?? (json['userId'] != null),
        message: json['message'] as String?,
      );
}
