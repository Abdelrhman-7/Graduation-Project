import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduationproject/data/local/local_booking_store.dart';
import 'package:graduationproject/data/models/booking/booking_model.dart';
import 'package:graduationproject/data/models/schudule/cliniceSchedual.dart';
import 'package:graduationproject/data/models/schudule/doctorModel.dart';
import 'package:graduationproject/data/repository/repository.dart';
import 'package:graduationproject/data/repository/shared_pref_controller.dart';
import 'patient_booking_state.dart';

class PatientBookingCubit extends Cubit<PatientBookingState> {
  final Repository repository;
  final SharedPrefController _prefs = SharedPrefController();

  PatientBookingCubit(this.repository) : super(PatientBookingInitial());

  List<DoctorModel> doctors = [];

  // Old flow support if needed
  Future<void> fetchClinics() async {
    emit(PatientBookingLoading());
    try {
      final clinics = await repository.getPatientAllClinics();
      emit(PatientBookingSuccess(clinics));
    } catch (e) {
      emit(PatientBookingError(e.toString()));
    }
  }

  // Old flow support if needed
  Future<bool> bookAppointment({
    required int clinicId,
    required String date,
    required String timeSlot,
  }) async {
    final currentState = state;
    try {
      emit(PatientBookingBooking());
      final result = await repository.createPatientBooking(
        clinicId: clinicId,
        date: date,
        timeSlot: timeSlot,
      );
      if (currentState is PatientBookingSuccess) {
        emit(PatientBookingSuccess(currentState.clinics));
      }
      return result;
    } catch (e) {
      if (currentState is PatientBookingSuccess) {
        emit(PatientBookingSuccess(currentState.clinics));
      }
      return false;
    }
  }

  // --- NEW WORKFLOW METHODS ---

  /// جلب كل الأطباء
  Future<void> fetchDoctors() async {
    emit(PatientBookingLoading());
    try {
      await repository.chooseRole('Patient');
      final fetchedDoctors = await repository.getPatientDoctors();
      if (fetchedDoctors.isEmpty) {
        emit(
          PatientBookingError(
            'No doctors found. Please log in as a patient and try again.',
          ),
        );
        return;
      }
      doctors = fetchedDoctors;
      emit(PatientBookingDoctorsSuccess(doctors));
    } catch (e) {
      emit(PatientBookingError(e.toString()));
    }
  }

  void restoreDoctorsList() {
    if (doctors.isNotEmpty) {
      emit(PatientBookingDoctorsSuccess(doctors));
    } else {
      fetchDoctors();
    }
  }

  /// يستعيد بيانات الطبيب عند الرجوع من DoctorClinicsView إلى DoctorProfileView
  void restoreDoctorDetails(DoctorModel doctor) {
    emit(PatientBookingDoctorDetailsSuccess(doctor));
  }

  /// يستعيد قائمة العيادات عند الرجوع من ClinicSchedulesView إلى DoctorClinicsView
  void restoreClinics(List<ClinicModel> clinics) {
    emit(PatientBookingClinicsSuccess(clinics));
  }

  /// يستعيد قائمة المواعيد عند الرجوع من BookAppointmentView إلى ClinicSchedulesView
  void restoreSchedules(List<dynamic> schedules) {
    emit(PatientBookingSchedulesSuccess(schedules));
  }

  /// جلب تفاصيل طبيب معين
  Future<void> fetchDoctorDetails(int doctorId, {DoctorModel? fallback}) async {
    emit(PatientBookingLoading());
    try {
      final doctor = await repository.getPatientDoctorDetails(doctorId);
      if (doctor != null) {
        emit(PatientBookingDoctorDetailsSuccess(doctor));
        return;
      }

      if (fallback != null && fallback.id == doctorId) {
        emit(PatientBookingDoctorDetailsSuccess(fallback));
        return;
      }

      emit(PatientBookingError('Doctor details not found.'));
    } catch (e) {
      if (fallback != null && fallback.id == doctorId) {
        emit(PatientBookingDoctorDetailsSuccess(fallback));
        return;
      }
      emit(PatientBookingError(e.toString()));
    }
  }

  /// جلب عيادات طبيب معين
  Future<void> fetchDoctorClinics(int doctorId) async {
    emit(PatientBookingLoading());
    try {
      await repository.chooseRole('Patient');
      final clinics = await repository.getPatientDoctorClinics(doctorId);

      // Workaround: Load local duration/notes since backend does not return them
      for (var clinic in clinics) {
        if (clinic.id != null) {
          final localData = await _prefs.getClinicLocalData(clinic.id!);
          if (localData['duration'] != null &&
              localData['duration']!.isNotEmpty) {
            clinic.appointmentDuration = localData['duration']!;
          }
          if (localData['notes'] != null && localData['notes']!.isNotEmpty) {
            clinic.nots = localData['notes']!;
          }
        }
      }

      emit(PatientBookingClinicsSuccess(clinics));
    } catch (e) {
      emit(PatientBookingError(e.toString()));
    }
  }

  /// جلب مواعيد عيادة معينة
  Future<void> fetchClinicSchedules(int clinicId, int doctorId) async {
    emit(PatientBookingLoading());
    try {
      await repository.chooseRole('Patient');
      final schedules = await repository.getPatientClinicSchedules(
        clinicId: clinicId,
      );
      emit(PatientBookingSchedulesSuccess(schedules));
    } catch (e) {
      emit(PatientBookingError(e.toString()));
    }
  }

  /// Helper to calculate the next date for a day of week
  DateTime _getNextDayOfWeek(String dayName) {
    final now = DateTime.now();
    final days = {
      'monday': DateTime.monday,
      'tuesday': DateTime.tuesday,
      'wednesday': DateTime.wednesday,
      'thursday': DateTime.thursday,
      'friday': DateTime.friday,
      'saturday': DateTime.saturday,
      'sunday': DateTime.sunday,
    };
    final targetDay = days[dayName.toLowerCase().trim()] ?? DateTime.sunday;
    int difference = targetDay - now.weekday;
    if (difference < 0) {
      difference += 7;
    }
    return now.add(Duration(days: difference));
  }

  /// Helper to parse duration to minutes
  int _parseDurationToMinutes(String? durationStr) {
    if (durationStr == null || durationStr.isEmpty) return 15;
    final cleaned = durationStr.toLowerCase().trim();
    int result = 15;
    if (cleaned.contains(':')) {
      final parts = cleaned.split(':');
      if (parts.length >= 2) {
        final hours = int.tryParse(parts[0]) ?? 0;
        final minutes = int.tryParse(parts[1]) ?? 0;
        result = (hours * 60) + minutes;
      }
    } else {
      final regExp = RegExp(r'\d+');
      final match = regExp.firstMatch(cleaned);
      if (match != null) {
        result = int.tryParse(match.group(0)!) ?? 15;
      }
    }
    return result <= 0 ? 15 : result;
  }

  /// Helper to parse time string to minutes
  int _parseTimeToMinutes(String timeStr) {
    final cleaned = timeStr.trim().toLowerCase();
    bool isPm = cleaned.contains('pm');
    bool isAm = cleaned.contains('am');
    final numberPart = cleaned.replaceAll(RegExp(r'[a-z]'), '').trim();
    final parts = numberPart.split(':');
    if (parts.isEmpty) return 0;

    int hour = int.tryParse(parts[0]) ?? 0;
    int minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

    if (isPm && hour < 12) hour += 12;
    if (isAm && hour == 12) hour = 0;

    return (hour * 60) + minute;
  }

  /// Helper to format minutes to HH:mm
  String _formatMinutesToTime(int totalMinutes) {
    int hour = totalMinutes ~/ 60;
    int minute = totalMinutes % 60;
    final hourStr = hour.toString().padLeft(2, '0');
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr';
  }

  /// حجز موعد — نجاح فوري بعد الحفظ المحلي مع حساب اليوم والوقت بدقة
  Future<bool> bookPatientAppointment({
    required int scheduleId,
    required String reasonForVisit,
    required String paymentMethod,
    int? doctorId,
    int? clinicId,
    String? clinicName,
    String? doctorName,
    String? doctorImageUrl,
    String? dayOfWeek,
    String? startTime,
    String? endTime,
    String? patientName,
    String? appointmentDuration,
    double? price,
  }) async {
    final currentState = state;
    emit(PatientBookingBooking());

    final name = patientName ?? await _prefs.getName() ?? 'Patient';
    final email = await _prefs.getEmail();
    final patientImg = await _prefs.getImage();

    // 1. حساب تاريخ وساعة الحجز بدقة
    DateTime targetDate = _getNextDayOfWeek(dayOfWeek ?? 'Sunday');
    final now = DateTime.now();
    int startMinutes = _parseTimeToMinutes(startTime ?? '09:00');
    
    // التحقق من أن الوقت لم يمر بعد إذا كان الحجز في نفس اليوم
    if (targetDate.year == now.year &&
        targetDate.month == now.month &&
        targetDate.day == now.day) {
      int nowMinutes = now.hour * 60 + now.minute;
      if (startMinutes <= nowMinutes) {
        targetDate = targetDate.add(const Duration(days: 7));
      }
    }
    
    final dateStr = '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';
    
    // حفظ التوقيت كما تم اختياره بالضبط
    final slotTimeStr = startTime ?? '10:00 AM';

    final pendingBooking = BookingModel(
      id: DateTime.now().millisecondsSinceEpoch,
      patientName: name,
      patientEmail: email,
      doctorName: doctorName,
      doctorImageUrl: doctorImageUrl,
      patientImageUrl: patientImg,
      reasonForVisit: reasonForVisit,
      clinicName: clinicName,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
      status: 'Pending',
      paymentMethod: paymentMethod,
      scheduleId: scheduleId,
      clinicId: clinicId,
      doctorId: doctorId,
      date: dateStr,
      time: slotTimeStr,
      createdAt: DateTime.now().toIso8601String(),
      price: price,
    );

    // استدعاء API الحجز مرة واحدة فقط، واستخراج الـ appointmentId الحقيقي
    int? serverAppointmentId;
    bool bookingSuccess = false;

    try {
      await repository.chooseRole('Patient');
      final apiResult = await repository.apiManager.bookPatientAppointment(
        scheduleId: scheduleId,
        reasonForVisit: reasonForVisit,
        paymentMethod: paymentMethod,
      );

      print('📋 Booking API result: $apiResult');

      if (apiResult != null) {
        if (apiResult is int) {
          // السيرفر رجع الـ ID مباشرة كـ integer
          serverAppointmentId = apiResult;
          bookingSuccess = true;
        } else if (apiResult is Map) {
          // السيرفر رجع object
          final idVal =
              apiResult['appointmentId'] ??
              apiResult['AppointmentId'] ??
              apiResult['id'] ??
              apiResult['Id'] ??
              apiResult['bookingId'] ??
              apiResult['BookingId'];
          if (idVal != null) {
            serverAppointmentId = idVal is int
                ? idVal
                : int.tryParse(idVal.toString());
          }
          bookingSuccess = true;
        } else if (apiResult is String) {
          // السيرفر رجع string (ممكن يكون ID أو رسالة نجاح)
          serverAppointmentId = int.tryParse(apiResult.trim());
          bookingSuccess = true;
        } else {
          bookingSuccess = true;
        }
      }
    } catch (e) {
      print('❌ Booking API error: $e');
    }

    // حفظ الحجز محلياً
    if (serverAppointmentId != null) {
      // Save with real server ID so it deduplicates and fetches full details from API later
      await LocalBookingStore.instance.addBooking(
        pendingBooking.copyWith(id: serverAppointmentId),
      );
    } else {
      // Offline fallback
      await LocalBookingStore.instance.addBooking(pendingBooking);
    }

    if (bookingSuccess) {
      print('✅ Booking success. Server appointmentId: $serverAppointmentId');
      emit(PatientBookingBookingSuccess(appointmentId: serverAppointmentId));
      return true;
    }

    emit(PatientBookingError('Failed to book appointment.'));
    if (currentState is PatientBookingSchedulesSuccess) {
      emit(PatientBookingSchedulesSuccess(currentState.schedules));
    }
    return false;
  }

  /// الدفع بالبطاقة الائتمانية
  Future<void> payAppointmentByCard({
    required int appointmentId,
    required double amount,
    required String cardHolderName,
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    String? doctorName,
  }) async {
    emit(PatientPaymentProcessing());
    try {
      final result = await repository.payAppointmentByCard(
        appointmentId: appointmentId,
        cardHolderName: cardHolderName,
        cardNumber: cardNumber,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        cvv: cvv,
      );
      final success = result['success'] == true;
      final message = result['message']?.toString() ?? '';
      if (success) {
        final patientName = await _prefs.getName() ?? 'Patient';
        await _prefs.addToDoctorWalletBalance(amount, doctorName: doctorName);
        await _prefs.addDoctorWalletTransaction(
          appointmentId: appointmentId,
          patientName: patientName,
          amount: amount,
          date: DateTime.now().toIso8601String(),
          doctorName: doctorName,
        );
        // Mark the appointment as Paid locally so it moves to Past in the schedule
        await LocalBookingStore.instance.updateStatus(appointmentId, 'Paid');
        emit(
          PatientPaymentSuccess(
            message.isNotEmpty ? message : 'Payment completed successfully!',
          ),
        );
      } else {
        emit(
          PatientPaymentError(
            message.isNotEmpty ? message : 'Payment failed. Please try again.',
          ),
        );
      }
    } catch (e) {
      emit(PatientPaymentError(e.toString()));
    }
  }
}
