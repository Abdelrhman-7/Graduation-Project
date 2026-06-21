import '../api/api_manager.dart';
import '../models/Auth/login_model.dart';
import '../models/Auth/register_model.dart';
import '../models/Auth/logout_model.dart';
import '../models/schudule/cliniceSchedual.dart';
import '../models/schudule/doctorModel.dart';

class Repository {
  Repository(this.apiManager);

  final ApiManager apiManager;

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

  Future<List<ClinicModel>> getAllClinics() async {
    return apiManager.getDoctorClinics();
  }

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

  // Patient: حجز موعد جديد
  Future<bool> bookPatientAppointment({
    required int scheduleId,
    required String reasonForVisit,
    required String paymentMethod,
  }) async {
    return apiManager.bookPatientAppointment(
      scheduleId: scheduleId,
      reasonForVisit: reasonForVisit,
      paymentMethod: paymentMethod,
    );
  }

  // Patient: جلب مواعيد الباشنت
  Future<List<dynamic>> getPatientAppointments() async {
    return apiManager.getPatientAppointments();
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

  Future<Map<String, dynamic>?> getPatientProfile() async {
    return apiManager.getPatientProfile();
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

  // ============================================================
  // Admin APIs
  // ============================================================

  Future<List<dynamic>> adminGetAllDoctors() async {
    return apiManager.adminGetAllDoctors();
  }

  Future<bool> adminDeleteDoctor(int id) async {
    return apiManager.adminDeleteDoctor(id);
  }

  Future<List<dynamic>> adminGetAllPatients() async {
    return apiManager.adminGetAllPatients();
  }

  Future<bool> adminDeletePatient(int id) async {
    return apiManager.adminDeletePatient(id);
  }
}

