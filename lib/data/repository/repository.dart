import 'dart:async';

import '../api/api_manager.dart';
import '../local/local_booking_store.dart';
import '../models/Auth/login_model.dart';
import 'shared_pref_controller.dart';
import '../models/Auth/register_model.dart';
import '../models/Auth/logout_model.dart';
import '../models/booking/booking_model.dart';
import '../models/schudule/cliniceSchedual.dart';
import '../models/schudule/doctorModel.dart';

class Repository {
  Repository(this.apiManager);

  final ApiManager apiManager;

  Future<void> _syncPatientAppointmentToServer({
    required int scheduleId,
    required String reasonForVisit,
    required String paymentMethod,
  }) async {
    try {
      await chooseRole('Patient');
      await apiManager.bookPatientAppointment(
        scheduleId: scheduleId,
        reasonForVisit: reasonForVisit,
        paymentMethod: paymentMethod,
      );
    } catch (e) {
      print('Background BookAppointment sync: $e');
    }
  }

  Future<void> _syncCancelBookingToServer(int bookingId) async {
    try {
      await apiManager.cancelPatientBooking(bookingId);
    } catch (e) {
      print('API cancel failed in background: $e');
    }
  }

  Future<void> _syncCancelDoctorAppointmentToServer(int bookingId) async {
    try {
      await apiManager.cancelDoctorAppointment(bookingId);
    } catch (e) {
      print('API doctor cancel failed in background: $e');
    }
  }

  // ==========================================
  //http://medicalsystem111.runasp.net/api/i
  // ==========================================

  Future<LoginResponse> login(String email, String password) async {
    return apiManager.login(LoginRequest(email: email, password: password));
  }

  // USER REGISTER
  Future<RegisterResponse> registerUser({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required String address,
    required String gender,
    required String dateOfBirth,
  }) async {
    return apiManager.register(
      isDoctor: false,

      request: RegisterRequest(
        fullName: fullName,

        userName: fullName.replaceAll(' ', ''),

        email: email,
        password: password,
        confirmPassword: password,
        phoneNumber: phoneNumber,
        address: address,
        gender: gender,
        dateOfBirth: dateOfBirth,
      ),
    );
  }

  // DOCTOR REGISTER
  Future<RegisterResponse> registerDoctor({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required String address,
    required String gender,
    required String dateOfBirth,

    required int departmentId,
    required String aboutMe,

    String? imageFile,
  }) async {
    return apiManager.register(
      isDoctor: true,

      request: RegisterRequest(
        fullName: fullName,
        email: email,
        password: password,
        confirmPassword: password,
        phoneNumber: phoneNumber,
        address: address,
        gender: gender,
        dateOfBirth: dateOfBirth,
        departmentId: departmentId,
        aboutMe: aboutMe,
        imageFile: imageFile,
      ),
    );
  }

  Future<RegisterResponse> forgetPassword(String email) async {
    return apiManager.forgetPassword(email);
  }

  Future<LogoutResponse> logout() async {
    return apiManager.logout();
  }

  Future<bool> chooseRole(String role) async {
    return apiManager.chooseRole(role);
  }

  // ==========================================
  // AppointmentApi
  // ==========================================

  Future<List<dynamic>> getPatientAllAppointments({int currentPage = 1}) async {
    return apiManager.getPatientAllAppointments(currentPage: currentPage);
  }

  Future<Map<String, dynamic>?> getPatientAppointment(int id) async {
    // Check if the ID is a local timestamp ID (e.g. 178...)
    if (id > 1000000000) {
      final localBookings = await LocalBookingStore.instance.getAll();
      try {
        final local = localBookings.firstWhere((b) => b.id == id);
        return {
          'id': local.id,
          'doctorName': local.doctorName ?? 'Doctor',
          'clinicName': local.clinicName,
          'specialty': local.clinicName ?? '',
          'bookingDate':
              local.date ?? local.createdAt ?? DateTime.now().toIso8601String(),
          'time': local.time ?? local.startTime,
          'status': local.status ?? 'Pending',
          'reasonForVisit': local.reasonForVisit ?? '',
          'price': local.price?.toString() ?? 'N/A',
          'paymentMethod': local.paymentMethod ?? 'Unknown',
          'paymentStatus':
              'NotPaid', // Local bookings are typically not paid yet
        };
      } catch (_) {
        // Not found locally
      }
    }
    return apiManager.getPatientAppointment(id);
  }

  Future<bool> editPatientAppointment(int id, Map<String, dynamic> data) async {
    return apiManager.editPatientAppointment(id, data);
  }

  Future<bool> deleteAppointmentPatientImage(int id) async {
    return apiManager.deleteAppointmentPatientImage(id);
  }

  Future<List<dynamic>> getDoctorAllAppointments({int currentPage = 1}) async {
    return apiManager.getDoctorAllAppointments(currentPage: currentPage);
  }

  Future<Map<String, dynamic>?> getDoctorAppointment(int id) async {
    return apiManager.getDoctorAppointment(id);
  }

  Future<bool> confirmDoctorAppointment(int id) async {
    return apiManager.confirmDoctorAppointment(id);
  }

  Future<bool> completeDoctorAppointment(int id) async {
    return apiManager.completeDoctorAppointment(id);
  }

  // ==========================================
  // BookingApi
  // ==========================================

  // Patient-specific: جلب كل العيادات للباشنت مع بيانات الطبيب
  Future<List<ClinicModel>> getPatientAllClinics() async {
    return apiManager.getPatientAllClinics();
  }

  // Patient: جلب الأطباء
  Future<List<DoctorModel>> getPatientDoctors() async {
    return apiManager.getPatientDoctors();
  }

  // Patient: جلب تفاصيل طبيب
  Future<DoctorModel?> getPatientDoctorDetails(int doctorId) async {
    return apiManager.getPatientDoctorDetails(doctorId);
  }

  // Patient: جلب عيادات طبيب
  Future<List<ClinicModel>> getPatientDoctorClinics(int doctorId) async {
    return apiManager.getPatientDoctorClinics(doctorId);
  }

  // Patient: حجز موعد جديد — يحفظ محلياً فوراً ويرسل للسيرفر في الخلفية
  Future<bool> bookPatientAppointment({
    required int scheduleId,
    required String reasonForVisit,
    required String paymentMethod,
    BookingModel? pendingBooking,
  }) async {
    if (pendingBooking != null) {
      await LocalBookingStore.instance.addBooking(pendingBooking);
      unawaited(
        _syncPatientAppointmentToServer(
          scheduleId: scheduleId,
          reasonForVisit: reasonForVisit,
          paymentMethod: paymentMethod,
        ),
      );
      return true;
    }

    await chooseRole('Patient');
    try {
      return await apiManager.bookPatientAppointment(
        scheduleId: scheduleId,
        reasonForVisit: reasonForVisit,
        paymentMethod: paymentMethod,
      );
    } catch (e) {
      print('BookAppointment failed: $e');
      return false;
    }
  }

  Future<dynamic> bookForOther(
    int scheduleId,
    Map<String, dynamic> data,
  ) async {
    return apiManager.bookForOther(scheduleId, data);
  }

  Future<Map<String, dynamic>?> getAppointmentSummary(int scheduleId) async {
    return apiManager.getAppointmentSummary(scheduleId);
  }

  Future<List<dynamic>> getPatientClinicSchedules({
    required int clinicId,
    int currentPage = 1,
    String? dayOfWeek,
  }) async {
    return apiManager.getPatientClinicSchedules(
      clinicId: clinicId,
      currentPage: currentPage,
      dayOfWeek: dayOfWeek,
    );
  }

  // Doctor: إدارة الحجوزات
  Future<List<BookingModel>> getDoctorPendingBookings() async {
    await chooseRole('Doctor');
    final apiBookings = await apiManager.getDoctorPendingBookings();
    if (apiBookings.isNotEmpty) return apiBookings;

    final clinics = await getAllClinics();
    final clinicIds = clinics.map((c) => c.id).whereType<int>().toSet();
    return LocalBookingStore.instance.getPendingForClinics(clinicIds);
  }

  Future<bool> acceptDoctorBooking(
    int bookingId, {
    BookingModel? booking,
  }) async {
    await chooseRole('Doctor');
    final apiOk = await apiManager.confirmDoctorAppointment(bookingId);
    if (booking != null) {
      await LocalBookingStore.instance.addBooking(
        booking.copyWith(status: 'Approved', notificationUnread: true),
      );
    } else {
      await LocalBookingStore.instance.updateStatus(bookingId, 'Approved');
    }
    return true;
  }

  Future<bool> rejectDoctorBooking(
    int bookingId, {
    BookingModel? booking,
  }) async {
    await chooseRole('Doctor');
    final apiOk = await apiManager.cancelDoctorAppointment(bookingId);
    if (booking != null) {
      await LocalBookingStore.instance.addBooking(
        booking.copyWith(status: 'Rejected', notificationUnread: true),
      );
    } else {
      await LocalBookingStore.instance.updateStatus(bookingId, 'Rejected');
    }
    return true;
  }

  Future<bool> completeDoctorBooking(
    int bookingId, {
    BookingModel? booking,
  }) async {
    await chooseRole('Doctor');
    await apiManager.completeDoctorAppointment(bookingId);
    if (booking != null) {
      await LocalBookingStore.instance.addBooking(
        booking.copyWith(status: 'Completed', notificationUnread: true),
      );
    } else {
      await LocalBookingStore.instance.updateStatus(bookingId, 'Completed');
    }
    return true;
  }

  Future<List<dynamic>> getClinicBookings(int clinicId) async {
    await chooseRole('Doctor');
    final apiBookings = await apiManager.getClinicBookings(clinicId);
    if (apiBookings.isNotEmpty) return apiBookings;

    final local = await LocalBookingStore.instance.getForClinic(
      clinicId,
      pendingOnly: true,
    );
    return local.map((b) => b.toJson()).toList();
  }

  Future<List<BookingModel>> getDoctorAllBookings() async {
    await chooseRole('Doctor');
    final apiBookingsRaw = await apiManager.getDoctorAllAppointments(
      currentPage: 1,
    );
    final apiBookings = apiBookingsRaw
        .whereType<Map<String, dynamic>>()
        .map(BookingModel.fromJson)
        .toList();
    final clinics = await getAllClinics();
    final clinicIds = clinics.map((c) => c.id).whereType<int>().toSet();
    final local = await LocalBookingStore.instance.getAllForClinics(clinicIds);
    
    if (apiBookings.isNotEmpty) {
      final mergedBookings = apiBookings.map((apiBooking) {
        try {
          final localData = local.firstWhere((l) => l.id == apiBooking.id);
          return apiBooking.copyWith(
            date: localData.date ?? apiBooking.date,
            time: localData.time ?? apiBooking.time,
          );
        } catch (_) {
          return apiBooking;
        }
      }).toList();
      
      // Add any local bookings that are NOT in apiBookings (e.g. rejected duplicates)
      final apiIds = apiBookings.map((b) => b.id).toSet();
      for (final localBooking in local) {
        if (!apiIds.contains(localBooking.id)) {
          mergedBookings.add(localBooking);
        }
      }
      
      return mergedBookings;
    }
    
    return local;
  }

  // Patient: جلب مواعيد الباشنت
  Future<List<dynamic>> getPatientAppointments() async {
    await chooseRole('Patient');
    final prefs = SharedPrefController();
    final name = await prefs.getName();
    final email = await prefs.getEmail();

    final local = await LocalBookingStore.instance.getBookingsForPatient(
      patientName: name,
      patientEmail: email,
    );

    // Fetch active bookings
    final api = await apiManager.getPatientAllAppointments(currentPage: 1);

    final localMaps = local.map((b) => b.toAppointmentMap()).toList();

    // Fetch history bookings (to automatically feed the UI's past appointments section)
    List<dynamic> historyApi = [];
    try {
      historyApi = await apiManager.getPatientHistoryAppointments(page: 1);
    } catch (e) {
      print(
        'Failed to load history appointments in getPatientAppointments: $e',
      );
    }

    final combinedApi = [...api, ...historyApi];

    final uniqueMaps = <dynamic>[];
    final seenIds = <dynamic>{};

    final currentEmail = email?.toLowerCase() ?? '';
    final currentName = name?.toLowerCase() ?? '';

    for (final item in combinedApi) {
      if (item is Map) {
        final id = item['id'] ?? item['bookingId'] ?? item['appointmentId'];
        if (id != null) {
          if (seenIds.contains(id)) continue;
          seenIds.add(id);
        }
        
        final parsed = BookingModel.fromJson(Map<String, dynamic>.from(item));
        
        // Merge local data to preserve paymentMethod and staggered dates from the smart algorithm
        BookingModel mergedParsed = parsed;
        try {
          final localData = localMaps.firstWhere((l) => l['id'] == id, orElse: () => <String, dynamic>{});
          if (localData.isNotEmpty) {
            final localBooking = BookingModel.fromJson(Map<String, dynamic>.from(localData));
            mergedParsed = parsed.copyWith(
              paymentMethod: parsed.paymentMethod ?? localBooking.paymentMethod,
              date: localBooking.date ?? parsed.date,
              time: localBooking.time ?? parsed.time,
            );
          }
        } catch (_) {}

        // Filter by patient email or name to prevent seeing other patients' appointments
        bool matches = true;
        if (currentEmail.isNotEmpty || currentName.isNotEmpty) {
          final pEmail = mergedParsed.patientEmail?.toLowerCase() ?? '';
          final pName = mergedParsed.patientName?.toLowerCase() ?? '';
          
          if (pEmail.isNotEmpty && currentEmail.isNotEmpty) {
            matches = pEmail == currentEmail;
          } else if (pName.isNotEmpty && currentName.isNotEmpty) {
            matches = pName == currentName;
          }
        }
        
        if (matches) {
          uniqueMaps.add(mergedParsed.toAppointmentMap());
        }
      } else {
        uniqueMaps.add(item);
      }
    }

    // Now add local maps only if their ID hasn't been seen from the API
    for (final local in localMaps) {
      final id = local['id'];
      if (id != null) {
        if (seenIds.contains(id)) continue;
        seenIds.add(id);
      }
      uniqueMaps.add(local);
    }
    
    return uniqueMaps.where((item) {
      if (item is Map) {
        final docName = item['doctorName']?.toString().toLowerCase().trim() ?? '';
        if (docName == 'doctor' || docName == 'unknown doctor' || docName.isEmpty) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  // Patient: حجز موعد
  Future<bool> createPatientBooking({
    required int clinicId,
    required String date,
    required String timeSlot,
  }) async {
    return apiManager.createPatientBooking(
      clinicId: clinicId,
      date: date,
      timeSlot: timeSlot,
    );
  }

  // ==========================================
  // ClinicApi
  // ==========================================

  Future<ClinicModel?> getClinic(int id) async {
    return apiManager.getClinic(id);
  }

  Future<List<ClinicModel>> getAllClinics() async {
    return apiManager.getDoctorClinics();
  }

  // ==========================================
  // DepartmentApi
  // ==========================================

  Future<List<dynamic>> getAllDepartments({int currentPage = 1}) async {
    return apiManager.getAllDepartments(currentPage: currentPage);
  }

  Future<Map<String, dynamic>?> getDepartment(int id) async {
    return apiManager.getDepartment(id);
  }

  Future<bool> createDepartment(Map<String, dynamic> data) async {
    return apiManager.createDepartment(data);
  }

  Future<bool> editDepartment(int id, Map<String, dynamic> data) async {
    return apiManager.editDepartment(id, data);
  }

  Future<bool> deleteDepartment(int id) async {
    return apiManager.deleteDepartment(id);
  }

  // ==========================================
  // DoctorApi
  // ==========================================

  // ============================================================
  // Admin APIs
  // ============================================================

  Future<bool> adminRegisterDoctor(RegisterRequest request) async {
    return apiManager.adminRegisterDoctor(request);
  }

  Future<List<dynamic>> adminGetAllDoctors() async {
    return apiManager.adminGetAllDoctors();
  }

  Future<bool> adminDeleteDoctor(int id) async {
    return apiManager.adminDeleteDoctor(id);
  }

  Future<bool> adminToggleDoctorLock(int doctorId) async {
    return apiManager.adminToggleDoctorLock(doctorId);
  }

  Future<bool> adminResetDoctorPassword(
    int doctorId,
    String newPassword,
    String confirmPassword,
  ) async {
    return apiManager.adminResetDoctorPassword(
      doctorId,
      newPassword,
      confirmPassword,
    );
  }

  Future<Map<String, dynamic>?> adminGetDoctor(int doctorId) async {
    return apiManager.adminGetDoctor(doctorId);
  }

  Future<bool> adminEditDoctor(
    int doctorId,
    Map<String, dynamic> data,
    String? imagePath,
  ) async {
    return apiManager.adminEditDoctor(doctorId, data, imagePath);
  }

  Future<bool> adminDeleteDoctorImage(int doctorId) async {
    return apiManager.adminDeleteDoctorImage(doctorId);
  }

  // ==========================================
  // HistoryApi
  // ==========================================

  // Patient/Doctor: سجل المواعيد (History)
  Future<List<dynamic>> getPatientHistory({int page = 1}) async {
    await chooseRole('Patient');
    return await apiManager.getPatientHistoryAppointments(page: page);
  }

  Future<Map<String, dynamic>?> getPatientHistoryDetails(int id) async {
    await chooseRole('Patient');
    return await apiManager.getPatientHistoryAppointmentDetails(id);
  }

  Future<List<dynamic>> getDoctorHistory({int page = 1}) async {
    await chooseRole('Doctor');
    return await apiManager.getDoctorHistoryAppointments(page: page);
  }

  Future<Map<String, dynamic>?> getDoctorHistoryDetails(int id) async {
    await chooseRole('Doctor');
    return await apiManager.getDoctorHistoryAppointmentDetails(id);
  }

  // ==========================================
  // NotificationApi
  // ==========================================

  Future<List<dynamic>> getPatientNotifications({int page = 1}) async {
    List<dynamic> apiList = [];
    try {
      apiList = await apiManager.getPatientNotificationsFromApi(page: page);
    } catch (_) {}

    final prefs = SharedPrefController();
    final name = await prefs.getName();
    final email = await prefs.getEmail();
    final localList = await LocalBookingStore.instance
        .getUnreadNotificationsForPatient(
          patientName: name,
          patientEmail: email,
        );

    final localMaps = localList
        .map(
          (b) => {
            'id': b.id,
            'title': b.status == 'Approved'
                ? 'Booking Approved'
                : 'Booking Rejected',
            'message':
                'Dr. ${b.doctorName ?? 'Doctor'} — ${b.clinicName ?? 'Clinic'}',
            'isRead': false,
            'createdAt': b.createdAt ?? DateTime.now().toIso8601String(),
            'status': b.status,
            'doctorName': b.doctorName,
            'clinicName': b.clinicName,
          },
        )
        .toList();

    return [...localMaps, ...apiList];
  }

  Future<Map<String, dynamic>?> getPatientNotificationById(int id) async {
    return apiManager.getPatientNotificationById(id);
  }

  Future<bool> discardPatientNotification(int id) async {
    return apiManager.discardPatientNotification(id);
  }

  Future<void> markPatientNotificationsRead() async {
    final prefs = SharedPrefController();
    final name = await prefs.getName();
    final email = await prefs.getEmail();
    await LocalBookingStore.instance.markAllNotificationsRead(
      patientName: name,
      patientEmail: email,
    );

    try {
      final apiList = await apiManager.getPatientNotificationsFromApi(page: 1);
      int maxId = 0;
      for (final item in apiList) {
        if (item is Map<String, dynamic>) {
          final idVal =
              item['id'] ??
              item['Id'] ??
              item['notificationId'] ??
              item['NotificationId'] ??
              0;
          final int id = idVal is int
              ? idVal
              : int.tryParse(idVal.toString()) ?? 0;
          if (id > maxId) {
            maxId = id;
          }
        }
      }
      if (maxId > 0) {
        await prefs.saveLastViewedNotificationId(maxId);
      }
    } catch (_) {}
  }

  // ==========================================
  // Doctor Notifications
  // ==========================================

  Future<List<dynamic>> getDoctorNotifications({int currentPage = 1}) async {
    return apiManager.getDoctorNotifications(currentPage: currentPage);
  }

  Future<dynamic> getDoctorNotification(int id) async {
    return apiManager.getDoctorNotification(id);
  }

  Future<bool> discardDoctorNotification(int id) async {
    return apiManager.discardDoctorNotification(id);
  }

  // ==========================================
  // PatientApi
  // ==========================================

  Future<bool> adminRegisterPatient(RegisterRequest request) async {
    return apiManager.adminRegisterPatient(request);
  }

  Future<List<dynamic>> adminGetAllPatients() async {
    return apiManager.adminGetAllPatients();
  }

  Future<bool> adminDeletePatient(int id) async {
    return apiManager.adminDeletePatient(id);
  }

  Future<bool> adminTogglePatientLock(int patientId) async {
    return apiManager.adminTogglePatientLock(patientId);
  }

  Future<bool> adminResetPatientPassword(
    int patientId,
    String newPassword,
    String confirmPassword,
  ) async {
    return apiManager.adminResetPatientPassword(
      patientId,
      newPassword,
      confirmPassword,
    );
  }

  Future<Map<String, dynamic>?> adminGetPatient(int patientId) async {
    return apiManager.adminGetPatient(patientId);
  }

  Future<bool> adminEditPatient(
    int patientId,
    Map<String, dynamic> data,
    String? imagePath,
  ) async {
    return apiManager.adminEditPatient(patientId, data, imagePath);
  }

  Future<bool> adminDeletePatientImage(int patientId) async {
    return apiManager.adminDeletePatientImage(patientId);
  }

  // ==========================================
  // ProfileApi
  // ==========================================

  Future<Map<String, dynamic>?> getPatientProfile() async {
    return apiManager.getPatientProfile();
  }

  Future<Map<String, dynamic>?> getDoctorProfile() async {
    return apiManager.getDoctorProfile();
  }

  Future<bool> deletePatientImage() async {
    return apiManager.deletePatientImage();
  }

  Future<bool> deletePatientAccount() async {
    return apiManager.deletePatientAccount();
  }

  Future<bool> deleteDoctorImage() async {
    return apiManager.deleteDoctorImage();
  }

  Future<bool> deleteDoctorAccount() async {
    return apiManager.deleteDoctorAccount();
  }

  Future<bool> changeDoctorPassword(
    String currentPassword,
    String newPassword,
    String confirmNewPassword,
  ) async {
    return apiManager.changeDoctorPassword(
      currentPassword,
      newPassword,
      confirmNewPassword,
    );
  }

  Future<bool> changePatientPassword(
    String currentPassword,
    String newPassword,
    String confirmNewPassword,
  ) async {
    return apiManager.changePatientPassword(
      currentPassword,
      newPassword,
      confirmNewPassword,
    );
  }

  // ==========================================
  // ScheduleApi
  // ==========================================

  Future<Map<String, dynamic>?> getSchedule(int id) async {
    return apiManager.getSchedule(id);
  }

  Future<List<dynamic>> getAllSchedules() async {
    return apiManager.getAllSchedules();
  }

  // ==========================================
  // Other
  // ==========================================

  Future<void> markPatientNotificationRead(int bookingId) async {
    await LocalBookingStore.instance.markNotificationRead(bookingId);
  }

  Future<bool> cancelPatientBooking(int bookingId) async {
    // Cancel locally first (immediate UI feedback)
    await LocalBookingStore.instance.updateStatus(bookingId, 'Cancelled');
    // Try API in background without awaiting it so the UI updates instantly
    _syncCancelBookingToServer(bookingId);
    return true;
  }

  Future<bool> cancelDoctorAppointment(int bookingId) async {
    await LocalBookingStore.instance.updateStatus(bookingId, 'Cancelled');
    _syncCancelDoctorAppointmentToServer(bookingId);
    return true;
  }

  // Patient: تعديل الملف الشخصي
  Future<bool> editPatientProfile({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? address,
    String? gender,
    String? dateOfBirth,
    String? imagePath,
  }) async {
    return apiManager.editPatientProfile(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      address: address,
      gender: gender,
      dateOfBirth: dateOfBirth,
      imagePath: imagePath,
    );
  }

  Future<bool> editDoctorProfile({
    String? fullName,
    String? phoneNumber,
    String? address,
    String? gender,
    String? dateOfBirth,
    int? departmentId,
    String? aboutMe,
    String? imagePath,
  }) async {
    return apiManager.editDoctorProfile(
      fullName: fullName,
      phoneNumber: phoneNumber,
      address: address,
      gender: gender,
      dateOfBirth: dateOfBirth,
      departmentId: departmentId,
      aboutMe: aboutMe,
      imagePath: imagePath,
    );
  }

  // ============================================================
  // Patient Health Metrics (Local Mock)
  // ============================================================
  Future<void> addPatientHealthMetricRecord(Map<String, dynamic> record) async {
    final prefs = SharedPrefController();
    await prefs.addHealthMetricRecord(record);
  }

  Future<List<String>> getPatientHealthMetricsHistory() async {
    final prefs = SharedPrefController();
    return await prefs.getHealthMetricsHistory();
  }

  Future<Map<String, String>> getPatientHealthMetrics() async {
    final prefs = SharedPrefController();
    return await prefs.getHealthMetrics();
  }

  /// دفع قيمة الحجز بالبطاقة الائتمانية
  Future<Map<String, dynamic>> payAppointmentByCard({
    required int appointmentId,
    required String cardHolderName,
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
  }) async {
    return apiManager.payAppointmentByCard(
      appointmentId: appointmentId,
      cardHolderName: cardHolderName,
      cardNumber: cardNumber,
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
      cvv: cvv,
    );
  }
}
