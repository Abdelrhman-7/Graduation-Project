class LoginRequest {
  final String email;
  final String password;
  final bool rememberMe;

  LoginRequest({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'rememberMe': rememberMe,
      };
}

class LoginData {
  final String? token;
  final String? email;
  final String? fullName;

  LoginData({this.token, this.email, this.fullName});

  factory LoginData.fromJson(Map<String, dynamic> json) => LoginData(
        token: json['token'] as String?,
        email: json['email'] as String?,
        fullName: json['fullName'] as String?,
      );
}

class LoginResponse {
  final bool? status;
  final String? message;
  final LoginData? data;

  LoginResponse({this.status, this.message, this.data});

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        status: json['status'] as bool?,
        message: json['message'] as String?,
        data: json['data'] != null
            ? LoginData.fromJson(json['data'] as Map<String, dynamic>)
            : null,
      );
}
