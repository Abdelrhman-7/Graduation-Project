import 'package:flutter/foundation.dart';
import 'package:graduationproject/data/models/booking/booking_model.dart';
import 'package:graduationproject/data/models/notification/doctor_notification_model.dart';

@immutable
abstract class DoctorHomeState {}

class DoctorHomeInitial extends DoctorHomeState {}

class DoctorHomeLoading extends DoctorHomeState {}

class DoctorHomeSuccess extends DoctorHomeState {
  final String doctorName;
  final String? imageUrl;
  final String specialty;
  final int? age;
  final int patientsToday;
  final Map<String, dynamic> upNextAppointment;
  final List<Map<String, dynamic>> patientRequests;
  final List<Map<String, dynamic>> todaySchedule;
  final List<BookingModel> pendingBookings;
  final List<BookingModel> allBookings;
  final List<BookingModel> historyBookings;
  final int pendingBookingsCount;
  final int? processingBookingId;
  final String? processingAction;

  // Added Notification Fields
  final List<DoctorNotificationModel> notifications;
  final int? processingNotificationId;

  DoctorHomeSuccess({
    required this.doctorName,
    this.imageUrl,
    required this.specialty,
    this.age,
    required this.patientsToday,
    required this.upNextAppointment,
    required this.patientRequests,
    required this.todaySchedule,
    this.pendingBookings = const [],
    this.allBookings = const [],
    this.historyBookings = const [],
    this.pendingBookingsCount = 0,
    this.processingBookingId,
    this.processingAction,
    this.notifications = const [],
    this.processingNotificationId,
  });

  DoctorHomeSuccess copyWith({
    String? doctorName,
    String? imageUrl,
    String? specialty,
    int? age,
    int? patientsToday,
    Map<String, dynamic>? upNextAppointment,
    List<Map<String, dynamic>>? patientRequests,
    List<Map<String, dynamic>>? todaySchedule,
    List<BookingModel>? pendingBookings,
    List<BookingModel>? allBookings,
    List<BookingModel>? historyBookings,
    int? pendingBookingsCount,
    int? processingBookingId,
    String? processingAction,
    bool clearProcessingBookingId = false,
    List<DoctorNotificationModel>? notifications,
    int? processingNotificationId,
    bool clearProcessingNotificationId = false,
  }) {
    return DoctorHomeSuccess(
      doctorName: doctorName ?? this.doctorName,
      imageUrl: imageUrl ?? this.imageUrl,
      specialty: specialty ?? this.specialty,
      age: age ?? this.age,
      patientsToday: patientsToday ?? this.patientsToday,
      upNextAppointment: upNextAppointment ?? this.upNextAppointment,
      patientRequests: patientRequests ?? this.patientRequests,
      todaySchedule: todaySchedule ?? this.todaySchedule,
      pendingBookings: pendingBookings ?? this.pendingBookings,
      allBookings: allBookings ?? this.allBookings,
      historyBookings: historyBookings ?? this.historyBookings,
      pendingBookingsCount: pendingBookingsCount ?? this.pendingBookingsCount,
      processingBookingId: clearProcessingBookingId ? null : (processingBookingId ?? this.processingBookingId),
      processingAction: clearProcessingBookingId ? null : (processingAction ?? this.processingAction),
      notifications: notifications ?? this.notifications,
      processingNotificationId: clearProcessingNotificationId ? null : (processingNotificationId ?? this.processingNotificationId),
    );
  }
}

class DoctorHomeError extends DoctorHomeState {
  final String message;
  DoctorHomeError(this.message);
}
