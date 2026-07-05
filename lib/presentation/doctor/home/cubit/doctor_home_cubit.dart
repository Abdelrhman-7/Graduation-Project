import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduationproject/data/models/booking/booking_model.dart';
import 'package:graduationproject/data/models/notification/doctor_notification_model.dart';
import 'package:graduationproject/data/repository/shared_pref_controller.dart';
import 'package:graduationproject/data/repository/repository.dart';
import 'doctor_home_state.dart';

class DoctorHomeCubit extends Cubit<DoctorHomeState> {
  final SharedPrefController _sharedPrefController = SharedPrefController();
  final Repository _repository;

  DoctorHomeCubit(this._repository) : super(DoctorHomeInitial());

  Future<void> getDoctorHomeData() async {
    emit(DoctorHomeLoading());
    try {
      String? apiImageUrl;
      String? apiName;
      String specialty = 'Medical Specialist';
      int? doctorAge;

      try {
        final profile = await _repository.getDoctorProfile();
        if (profile != null) {
          apiName = profile['fullName'] ??
              profile['FullName'] ??
              profile['name'] ??
              profile['Name'];
          specialty = profile['departmentName'] as String? ??
              profile['DepartmentName'] as String? ??
              (profile['department'] is Map
                  ? (profile['department'] as Map)['name'] as String?
                  : null) ??
              specialty;
          final rawImage = profile['displayImageUrl'] ??
              profile['imageUrl'] ??
              profile['ImageUrl'] ??
              profile['profileImageUrl'] ??
              profile['ProfileImageUrl'];

          if (rawImage != null && rawImage.toString().isNotEmpty) {
            final raw = rawImage.toString();
            apiImageUrl = raw.startsWith('http')
                ? raw
                : 'http://clinicbook.runasp.net$raw';
          }

          final dobString = profile['dateOfBirth'] ?? profile['DateOfBirth'];
          if (dobString != null && dobString.toString().isNotEmpty) {
            try {
              final dob = DateTime.parse(dobString.toString());
              final today = DateTime.now();
              int age = today.year - dob.year;
              if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
                age--;
              }
              doctorAge = age;
            } catch (_) {}
          }
          
          if (doctorAge == null) {
            final ageVal = profile['age'] ?? profile['Age'];
            if (ageVal != null) {
              doctorAge = int.tryParse(ageVal.toString());
            }
          }

          if (apiName != null && apiName.isNotEmpty) {
            await _sharedPrefController.saveName(apiName);
          }
          if (apiImageUrl != null && apiImageUrl.isNotEmpty) {
            await _sharedPrefController.saveImage(apiImageUrl);
          }
        }
      } catch (e) {
        print('Error refreshing doctor profile in Home Cubit: $e');
      }

      final storedName = await _sharedPrefController.getName();
      final storedImage = await _sharedPrefController.getImage();
      final doctorName = apiName ?? storedName ?? 'Doctor';
      final imageUrl = apiImageUrl ?? storedImage;

      List<BookingModel> allBookings = [];
      List<BookingModel> pendingBookings = [];
      List<DoctorNotificationModel> notifications = [];
      try {
        allBookings = await _repository.getDoctorAllBookings();
        pendingBookings =
            allBookings.where((b) => b.isPending).toList();
      } catch (e) {
        print('Failed to load bookings: $e');
      }

      try {
        final notificationsRaw = await _repository.getDoctorNotifications(currentPage: 1);
        notifications = notificationsRaw
            .whereType<Map<String, dynamic>>()
            .map((n) => DoctorNotificationModel.fromJson(n))
            .toList();
      } catch (e) {
        print('Failed to load doctor notifications: $e');
      }

      final patientRequests =
          pendingBookings.map((b) => b.toRequestMap()).toList();

      Map<String, dynamic> upNext = {
        'patientName': 'No upcoming appointments',
        'time': '',
        'type': 'Waiting for bookings',
        'status': 'Empty',
      };

      List<Map<String, dynamic>> todaySchedule = [];

      if (pendingBookings.isNotEmpty) {
        final next = pendingBookings.first;
        upNext = {
          'patientName': next.patientName,
          'time': next.startTime ?? next.time ?? 'Pending',
          'type': next.clinicName ?? 'New Booking',
          'status': 'Pending Approval',
        };
      } else if (allBookings.isNotEmpty) {
        final next = allBookings.firstWhere(
          (b) => b.isApproved,
          orElse: () => allBookings.first,
        );
        upNext = {
          'patientName': next.patientName,
          'time': next.startTime ?? next.time ?? '',
          'type': next.clinicName ?? 'Booking',
          'status': next.status ?? 'Scheduled',
        };
      }

      try {
        final schedules = await _repository.getAllSchedules();
        todaySchedule = schedules
            .whereType<Map<String, dynamic>>()
            .map((s) {
              return {
                'time': s['startTime'] ?? s['StartTime'] ?? '',
                'title': s['dayOfWeek'] ?? s['DayOfWeek'] ?? 'Schedule',
                'patient': s['clinicName'] ?? s['notes'] ?? '',
              };
            })
            .toList();
      } catch (e) {
        print('Failed to load today schedule: $e');
      }

      List<BookingModel> historyBookings = [];
      try {
        final historyRaw = await _repository.getDoctorHistory(page: 1);
        historyBookings = historyRaw
            .whereType<Map<String, dynamic>>()
            .map((b) => BookingModel.fromJson(b))
            .toList();
      } catch (e) {
        print('Failed to load doctor history bookings: $e');
      }

      emit(DoctorHomeSuccess(
        doctorName: doctorName,
        imageUrl: imageUrl,
        specialty: specialty,
        age: doctorAge,
        patientsToday: allBookings.length,
        upNextAppointment: upNext,
        patientRequests: patientRequests,
        todaySchedule: todaySchedule,
        pendingBookings: pendingBookings,
        allBookings: allBookings,
        historyBookings: historyBookings,
        pendingBookingsCount: pendingBookings.length,
        notifications: notifications,
      ));
    } catch (e) {
      emit(DoctorHomeError(e.toString()));
    }
  }

  Future<void> refreshBookings() async {
    final current = state;
    if (current is! DoctorHomeSuccess) {
      await getDoctorHomeData();
      return;
    }

    try {
      final allBookings = await _repository.getDoctorAllBookings();
      final pendingBookings =
          allBookings.where((b) => b.isPending).toList();
      final patientRequests =
          pendingBookings.map((b) => b.toRequestMap()).toList();

      List<BookingModel> historyBookings = [];
      try {
        final historyRaw = await _repository.getDoctorHistory(page: 1);
        historyBookings = historyRaw
            .whereType<Map<String, dynamic>>()
            .map((b) => BookingModel.fromJson(b))
            .toList();
      } catch (e) {
        print('Failed to load doctor history bookings in refresh: $e');
      }

      emit(current.copyWith(
        allBookings: allBookings,
        pendingBookings: pendingBookings,
        pendingBookingsCount: pendingBookings.length,
        patientRequests: patientRequests,
        patientsToday: allBookings.length,
        historyBookings: historyBookings,
        clearProcessingBookingId: true,
      ));
    } catch (e) {
      emit(current.copyWith(clearProcessingBookingId: true));
    }
  }

  Future<bool> acceptBooking(int bookingId) async {
    final current = state;
    if (current is! DoctorHomeSuccess) return false;

    emit(current.copyWith(processingBookingId: bookingId, processingAction: 'approve'));
    try {
      BookingModel? bookingModel;
      try {
        bookingModel = current.allBookings.firstWhere((b) => b.id == bookingId);
      } catch (_) {}

      final success = await _repository.acceptDoctorBooking(bookingId, booking: bookingModel);
      if (success) {
        await refreshBookings();
      } else {
        emit(current.copyWith(clearProcessingBookingId: true));
      }
      return success;
    } catch (e) {
      emit(current.copyWith(clearProcessingBookingId: true));
      return false;
    }
  }

  Future<bool> rejectBooking(int bookingId) async {
    final current = state;
    if (current is! DoctorHomeSuccess) return false;

    emit(current.copyWith(processingBookingId: bookingId, processingAction: 'deny'));
    try {
      BookingModel? bookingModel;
      try {
        bookingModel = current.allBookings.firstWhere((b) => b.id == bookingId);
      } catch (_) {}

      final success = await _repository.rejectDoctorBooking(bookingId, booking: bookingModel);
      if (success) {
        await refreshBookings();
      } else {
        emit(current.copyWith(clearProcessingBookingId: true));
      }
      return success;
    } catch (e) {
      emit(current.copyWith(clearProcessingBookingId: true));
      return false;
    }
  }

  Future<bool> completeBooking(int bookingId) async {
    final current = state;
    if (current is! DoctorHomeSuccess) return false;

    emit(current.copyWith(processingBookingId: bookingId, processingAction: 'complete'));
    try {
      BookingModel? bookingModel;
      try {
        bookingModel = current.allBookings.firstWhere((b) => b.id == bookingId);
      } catch (_) {}

      final success = await _repository.completeDoctorBooking(bookingId, booking: bookingModel);
      if (success) {
        await refreshBookings();
      } else {
        emit(current.copyWith(clearProcessingBookingId: true));
      }
      return success;
    } catch (e) {
      emit(current.copyWith(clearProcessingBookingId: true));
      return false;
    }
  }

  Future<void> refreshNotifications() async {
    final current = state;
    if (current is! DoctorHomeSuccess) return;

    try {
      final notificationsRaw = await _repository.getDoctorNotifications(currentPage: 1);
      final notifications = notificationsRaw
          .whereType<Map<String, dynamic>>()
          .map((n) => DoctorNotificationModel.fromJson(n))
          .toList();

      emit(current.copyWith(notifications: notifications));
    } catch (e) {
      print('Failed to refresh doctor notifications: $e');
    }
  }

  Future<bool> discardNotification(int notificationId) async {
    final current = state;
    if (current is! DoctorHomeSuccess) return false;

    emit(current.copyWith(processingNotificationId: notificationId));
    try {
      final success = await _repository.discardDoctorNotification(notificationId);
      if (success) {
        await refreshNotifications();
        if (state is DoctorHomeSuccess) {
           emit((state as DoctorHomeSuccess).copyWith(clearProcessingNotificationId: true));
        }
      } else {
        emit(current.copyWith(clearProcessingNotificationId: true));
      }
      return success;
    } catch (e) {
      emit(current.copyWith(clearProcessingNotificationId: true));
      return false;
    }
  }
}
