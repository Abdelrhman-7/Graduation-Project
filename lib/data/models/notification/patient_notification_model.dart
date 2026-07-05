class PatientNotificationModel {
  final int id;
  final String? title;
  final String? message;
  final String? type;
  final bool isRead;
  final String? createdAt;
  final String? doctorName;
  final String? clinicName;
  final String? status;
  final int? appointmentId;

  PatientNotificationModel({
    required this.id,
    this.title,
    this.message,
    this.type,
    this.isRead = false,
    this.createdAt,
    this.doctorName,
    this.clinicName,
    this.status,
    this.appointmentId,
  });

  factory PatientNotificationModel.fromJson(Map<String, dynamic> json) {
    final booking = json['booking'] ?? json['Booking'];
    String? doctorName =
        json['doctorName'] as String? ?? json['DoctorName'] as String?;
    String? clinicName =
        json['clinicName'] as String? ?? json['ClinicName'] as String?;
    String? status = json['status'] as String? ?? json['Status'] as String?;

    if (booking is Map<String, dynamic>) {
      doctorName ??=
          booking['doctorName'] as String? ?? booking['DoctorName'] as String?;
      clinicName ??=
          booking['clinicName'] as String? ?? booking['ClinicName'] as String?;
      status ??= booking['status'] as String? ?? booking['Status'] as String?;
    }

    int id = 0;
    final rawId = json['id'] ??
        json['Id'] ??
        json['notificationId'] ??
        json['NotificationId'];
    if (rawId is int) {
      id = rawId;
    } else if (rawId != null) {
      id = int.tryParse(rawId.toString()) ?? 0;
    }

    bool isRead = false;
    final rawRead =
        json['isRead'] ?? json['IsRead'] ?? json['isViewed'] ?? json['IsViewed'];
    if (rawRead is bool) isRead = rawRead;

    // Extract appointmentId from multiple possible sources
    int? appointmentId;
    final rawApptId = json['appointmentId'] ??
        json['AppointmentId'] ??
        json['bookingId'] ??
        json['BookingId'] ??
        (booking is Map ? (booking['id'] ?? booking['Id'] ?? booking['appointmentId'] ?? booking['bookingId']) : null);
    if (rawApptId != null) {
      appointmentId = rawApptId is int ? rawApptId : int.tryParse(rawApptId.toString());
    }

    return PatientNotificationModel(
      id: id,
      title: json['title'] as String? ??
          json['Title'] as String? ??
          json['subject'] as String? ??
          json['Subject'] as String?,
      message: json['message'] as String? ??
          json['Message'] as String? ??
          json['body'] as String? ??
          json['Body'] as String? ??
          json['content'] as String? ??
          json['Content'] as String?,
      type: json['type'] as String? ?? json['Type'] as String?,
      isRead: isRead,
      createdAt: json['createdAt'] as String? ??
          json['CreatedAt'] as String? ??
          json['date'] as String? ??
          json['Date'] as String?,
      doctorName: doctorName,
      clinicName: clinicName,
      status: status,
      appointmentId: appointmentId,
    );
  }

  bool get isApproved {
    final s = (status ?? title ?? message ?? '').toLowerCase();
    return s.contains('approved') || s.contains('accept');
  }

  bool get isRejected {
    final s = (status ?? title ?? message ?? '').toLowerCase();
    return s.contains('reject') || s.contains('denied') || s.contains('deny');
  }
}
