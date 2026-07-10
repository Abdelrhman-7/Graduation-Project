class BookingModel {
  final int id;
  final String patientName;
  final String? patientEmail;
  final String? doctorName;
  final String? doctorImageUrl;
  final String? patientImageUrl;
  final String? reasonForVisit;
  final String? clinicName;
  final String? date;
  final String? time;
  final String? dayOfWeek;
  final String? startTime;
  final String? endTime;
  final String? status;
  final String? paymentMethod;
  final int? scheduleId;
  final int? clinicId;
  final int? doctorId;
  final String? createdAt;
  final bool notificationUnread;
  final double? price;

  BookingModel({
    required this.id,
    required this.patientName,
    this.patientEmail,
    this.doctorName,
    this.doctorImageUrl,
    this.patientImageUrl,
    this.reasonForVisit,
    this.clinicName,
    this.date,
    this.time,
    this.dayOfWeek,
    this.startTime,
    this.endTime,
    this.status,
    this.paymentMethod,
    this.scheduleId,
    this.clinicId,
    this.doctorId,
    this.createdAt,
    this.notificationUnread = false,
    this.price,
  });

  static int _parseId(Map<String, dynamic> json) {
    final raw = json['bookingId'] ??
        json['BookingId'] ??
        json['id'] ??
        json['Id'];
    if (raw is int) return raw;
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  bool get isPending {
    final s = (status ?? '').toLowerCase();
    return s.isEmpty ||
        s.contains('pending') ||
        s.contains('waiting') ||
        s.contains('new') ||
        s == '0';
  }

  bool get isApproved {
    final s = (status ?? '').toLowerCase();
    return s.contains('approved') || s.contains('accept');
  }

  bool get isRejected {
    final s = (status ?? '').toLowerCase();
    return s.contains('reject') || s.contains('denied') || s.contains('deny');
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final patient = json['patient'];
    String patientName = json['patientName'] as String? ??
        json['PatientName'] as String? ??
        json['fullName'] as String? ??
        json['FullName'] as String? ??
        'Unknown Patient';

    String? patientImageUrl;
    if (patient is Map<String, dynamic>) {
      patientName = patient['fullName'] as String? ??
          patient['FullName'] as String? ??
          patient['name'] as String? ??
          patientName;

      final rawPatientImg = patient['imageUrl'] ?? patient['ImageUrl'] ??
          patient['profileImageUrl'] ?? patient['ProfileImageUrl'] ??
          patient['displayImageUrl'] ?? patient['DisplayImageUrl'] ??
          patient['imagePath'] ?? patient['ImagePath'] ??
          patient['image'] ?? patient['photo'] ?? patient['photoUrl'];
      if (rawPatientImg != null && rawPatientImg.toString().isNotEmpty) {
        final s = rawPatientImg.toString().trim();
        patientImageUrl = s.startsWith('http')
            ? s
            : 'http://mediconnect.somee.com${s.startsWith('/') ? '' : '/'}$s';
      }
    }

    if (patientImageUrl == null) {
      final rawPatientImg = json['patientImageUrl'] ?? json['PatientImageUrl'] ??
          json['patientImage'] ?? json['PatientImage'] ??
          json['patientImagePath'] ?? json['patientImagePath'] ??
          json['imagePath'] ?? json['ImagePath'];
      if (rawPatientImg != null && rawPatientImg.toString().isNotEmpty) {
        final s = rawPatientImg.toString().trim();
        patientImageUrl = s.startsWith('http')
            ? s
            : 'http://mediconnect.somee.com${s.startsWith('/') ? '' : '/'}$s';
      }
    }

    final clinic = json['clinic'];
    String? clinicName =
        json['clinicName'] as String? ?? json['ClinicName'] as String?;
    if (clinic is Map<String, dynamic>) {
      clinicName =
          clinic['name'] as String? ?? clinic['Name'] as String? ?? clinicName;
    }

    final schedule = json['schedule'] ?? json['Schedule'];
    String? dayOfWeek =
        json['dayOfWeek'] as String? ?? json['DayOfWeek'] as String?;
    String? startTime =
        json['startTime'] as String? ?? json['StartTime'] as String?;
    String? endTime = json['endTime'] as String? ?? json['EndTime'] as String?;

    if (schedule is Map<String, dynamic>) {
      dayOfWeek ??=
          schedule['dayOfWeek'] as String? ?? schedule['DayOfWeek'] as String?;
      startTime ??=
          schedule['startTime'] as String? ?? schedule['StartTime'] as String?;
      endTime ??=
          schedule['endTime'] as String? ?? schedule['EndTime'] as String?;
    }

    // Resolve doctor image URL from all possible sources
    String? resolvedImageUrl;
    final rawImg = json['doctorImageUrl'] ?? json['DoctorImageUrl'] ??
        json['imageUrl'] ?? json['ImageUrl'] ??
        json['profileImageUrl'] ?? json['ProfileImageUrl'] ??
        json['displayImageUrl'] ?? json['DisplayImageUrl'];
    if (rawImg != null && rawImg.toString().isNotEmpty) {
      final s = rawImg.toString().trim();
      resolvedImageUrl = s.startsWith('http')
          ? s
          : 'http://mediconnect.somee.com${s.startsWith('/') ? '' : '/'}$s';
    }
    // Also check inside doctor/schedule.doctor
    if (resolvedImageUrl == null) {
      final doc = json['doctor'] ?? json['Doctor'];
      final schedDoc = (json['schedule'] ?? json['Schedule']) is Map
          ? ((json['schedule'] ?? json['Schedule']) as Map)['doctor'] ?? ((json['schedule'] ?? json['Schedule']) as Map)['Doctor']
          : null;
      final src = (doc is Map ? (doc['imageUrl'] ?? doc['ImageUrl'] ?? doc['profileImageUrl'] ?? doc['ProfileImageUrl'] ?? doc['displayImageUrl'] ?? doc['DisplayImageUrl']) : null)
          ?? (schedDoc is Map ? (schedDoc['imageUrl'] ?? schedDoc['ImageUrl'] ?? schedDoc['profileImageUrl'] ?? schedDoc['ProfileImageUrl'] ?? schedDoc['displayImageUrl'] ?? schedDoc['DisplayImageUrl']) : null);
      if (src != null && src.toString().isNotEmpty) {
        final s = src.toString().trim();
        resolvedImageUrl = s.startsWith('http')
            ? s
            : 'http://mediconnect.somee.com${s.startsWith('/') ? '' : '/'}$s';
      }
    }

    return BookingModel(
      id: _parseId(json),
      patientName: patientName,
      patientEmail: json['patientEmail'] as String? ??
          json['PatientEmail'] as String?,
      doctorName: json['doctorName'] as String? ??
          json['DoctorName'] as String? ??
          json['doctorFullName'] as String? ??
          json['DoctorFullName'] as String? ??
          json['userName'] as String? ??
          json['UserName'] as String? ??
          (json['doctor'] != null
              ? (json['doctor']['fullName'] as String? ??
                  json['doctor']['FullName'] as String? ??
                  json['doctor']['name'] as String? ??
                  json['doctor']['Name'] as String? ??
                  json['doctor']['userName'] as String? ??
                  json['doctor']['UserName'] as String?)
              : null),
      doctorImageUrl: resolvedImageUrl,
      patientImageUrl: patientImageUrl,
      reasonForVisit: json['reasonForVisit'] as String? ??
          json['ReasonForVisit'] as String?,
      clinicName: clinicName,
      date: json['date'] as String? ??
          json['bookingDate'] as String? ??
          json['BookingDate'] as String?,
      time: json['time'] as String? ??
          json['timeSlot'] as String? ??
          json['TimeSlot'] as String?,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
      status: json['status'] as String? ?? json['Status'] as String?,
      paymentMethod: json['paymentMethod'] as String? ??
          json['PaymentMethod'] as String?,
      scheduleId: json['scheduleId'] is int
          ? json['scheduleId'] as int
          : int.tryParse(json['scheduleId']?.toString() ?? ''),
      clinicId: json['clinicId'] is int
          ? json['clinicId'] as int
          : int.tryParse(json['clinicId']?.toString() ?? ''),
      doctorId: json['doctorId'] is int
          ? json['doctorId'] as int
          : int.tryParse(json['doctorId']?.toString() ?? ''),
      createdAt: json['createdAt'] as String? ?? json['CreatedAt'] as String?,
      notificationUnread: json['notificationUnread'] == true ||
          json['NotificationUnread'] == true,
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': id,
      'patientName': patientName,
      'patientEmail': patientEmail,
      'doctorName': doctorName,
      'doctorImageUrl': doctorImageUrl,
      'patientImageUrl': patientImageUrl,
      'reasonForVisit': reasonForVisit,
      'clinicName': clinicName,
      'date': date,
      'time': time,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'paymentMethod': paymentMethod,
      'scheduleId': scheduleId,
      'clinicId': clinicId,
      'doctorId': doctorId,
      'createdAt': createdAt,
      'notificationUnread': notificationUnread,
      'price': price,
    };
  }

  BookingModel copyWith({
    int? id,
    String? status,
    bool? notificationUnread,
    String? paymentMethod,
    String? date,
    String? time,
    String? doctorImageUrl,
    String? patientImageUrl,
    String? doctorName,
    String? clinicName,
  }) {
    return BookingModel(
      id: id ?? this.id,
      patientName: patientName,
      patientEmail: patientEmail,
      doctorName: doctorName ?? this.doctorName,
      doctorImageUrl: doctorImageUrl ?? this.doctorImageUrl,
      patientImageUrl: patientImageUrl ?? this.patientImageUrl,
      reasonForVisit: reasonForVisit,
      clinicName: clinicName ?? this.clinicName,
      date: date ?? this.date,
      time: time ?? this.time,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      scheduleId: scheduleId,
      clinicId: clinicId,
      doctorId: doctorId,
      createdAt: createdAt,
      notificationUnread: notificationUnread ?? this.notificationUnread,
      price: price,
    );
  }

  Map<String, dynamic> toAppointmentMap() {
    final timeLabel = (dayOfWeek != null && time != null)
        ? '$dayOfWeek $time'
        : (dayOfWeek != null
            ? '${dayOfWeek!} ${startTime ?? ''}${endTime != null ? ' - $endTime' : ''}'.trim()
            : time);

    return {
      'id': id,
      'doctorName': doctorName ?? 'Doctor',
      'doctorImageUrl': doctorImageUrl,
      'patientImageUrl': patientImageUrl,
      'clinicName': clinicName,
      'specialty': clinicName ?? '',
      'bookingDate': date ?? createdAt ?? DateTime.now().toIso8601String(),
      'timeSlot': timeLabel ?? '',
      'status': status,
      'price': price,
      'paymentMethod': paymentMethod,
      'patientName': patientName,
      'patientEmail': patientEmail,
    };
  }

  Map<String, dynamic> toRequestMap() {
    final timeLabel = _formatScheduleTime();
    return {
      'id': id,
      'patientName': patientName,
      'type': isPending ? 'New Booking' : (status ?? 'Booking'),
      'details': reasonForVisit?.isNotEmpty == true
          ? reasonForVisit!
          : (clinicName ?? 'Appointment request'),
      'time': timeLabel,
      'clinicName': clinicName,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'paymentMethod': paymentMethod,
      'isPending': isPending,
      'date': date,
      'patientImageUrl': patientImageUrl,
    };
  }

  String _formatScheduleTime() {
    if (dayOfWeek != null && time != null) {
      return '$dayOfWeek $time';
    }
    if (dayOfWeek != null && startTime != null) {
      return '$dayOfWeek $startTime${endTime != null ? ' - $endTime' : ''}';
    }
    if (date != null && time != null) return '$date at $time';
    if (date != null) return date!;
    if (createdAt != null) return createdAt!;
    return 'Recently';
  }
}
