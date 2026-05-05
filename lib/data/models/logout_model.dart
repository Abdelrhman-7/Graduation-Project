class LogoutResponse {
  final bool status;
  final String message;

  LogoutResponse({
    required this.status,
    required this.message,
  });

  factory LogoutResponse.fromJson(Map<String, dynamic> json) {
    return LogoutResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
