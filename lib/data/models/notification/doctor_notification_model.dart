class DoctorNotificationModel {
  final int id;
  final String? title;
  final String? message;
  final String? type;
  final bool isRead;
  final String? createdAt;
  final String? patientName;
  final String? clinicName;
  final String? status;
  final int? appointmentId;

  DoctorNotificationModel({
    required this.id,
    this.title,
    this.message,
    this.type,
    this.isRead = false,
    this.createdAt,
    this.patientName,
    this.clinicName,
    this.status,
    this.appointmentId,
  });

  factory DoctorNotificationModel.fromJson(Map<String, dynamic> json) {
    final booking = json['booking'] ?? json['Booking'];
    String? patientName =
        json['patientName'] as String? ?? json['PatientName'] as String?;
    String? clinicName =
        json['clinicName'] as String? ?? json['ClinicName'] as String?;
    String? status = json['status'] as String? ?? json['Status'] as String?;

    if (booking is Map<String, dynamic>) {
      patientName ??=
          booking['patientName'] as String? ?? booking['PatientName'] as String?;
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

    return DoctorNotificationModel(
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
      patientName: patientName,
      clinicName: clinicName,
      status: status,
      appointmentId: appointmentId,
    );
  }
}
