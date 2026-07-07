import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefController {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _tokenKey = 'auth_token';
  static const String _emailKey = 'user_email';
  static const String _nameKey = 'user_name';
  static const String _imageKey = 'user_image';
  static const String _roleKey = 'user_role';

  Future<bool> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> setLoggedIn(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, value);
  }

  Future<void> saveLogin(String email) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_emailKey, email);
    // مسح الاسم والصورة القديمة عشان مفيش داتا تدخل في بعض
    await prefs.remove(_nameKey);
    await prefs.remove(_imageKey);
  }

  Future<String?> getEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  Future<void> saveUserInfo(String name, String? image) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    if (image != null) {
      await prefs.setString(_imageKey, image);
    }
  }

  Future<String?> getName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }

  Future<void> saveName(String name) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
  }

  Future<void> saveImage(String image) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_imageKey, image);
  }

  Future<void> saveEmail(String email) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
  }

  Future<String?> getImage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_imageKey);
  }

  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.remove(_tokenKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_imageKey);
    await prefs.remove('auth_cookies');
    await prefs.remove(_roleKey);
  }

  Future<void> saveRole(String role) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role);
  }

  Future<String?> getRole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  Future<void> saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveCookies(String cookies) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_cookies', cookies);
  }

  Future<String?> getCookies() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_cookies');
  }

  Future<void> clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static const String _lastViewedNotificationIdKey =
      'last_viewed_notification_id';
  static const String _lastViewedDoctorNotificationIdKey =
      'last_viewed_doctor_notification_id';

  Future<void> saveLastViewedNotificationId(int id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final currentMax = prefs.getInt(_lastViewedNotificationIdKey) ?? 0;
    if (id > currentMax) {
      await prefs.setInt(_lastViewedNotificationIdKey, id);
    }
  }

  Future<int> getLastViewedNotificationId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastViewedNotificationIdKey) ?? 0;
  }

  Future<void> saveLastViewedDoctorNotificationId(int id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final currentMax = prefs.getInt(_lastViewedDoctorNotificationIdKey) ?? 0;
    if (id > currentMax) {
      await prefs.setInt(_lastViewedDoctorNotificationIdKey, id);
    }
  }

  Future<int> getLastViewedDoctorNotificationId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastViewedDoctorNotificationIdKey) ?? 0;
  }

  // --- Doctor Wallet Integration ---
  static const String _doctorWalletBalanceKey = 'doctor_wallet_balance';
  static const String _doctorWalletTransactionsKey =
      'doctor_wallet_transactions';

  Future<double> getDoctorWalletBalance({String? doctorName}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final name = doctorName ?? await getName();
    final key = name != null && name.isNotEmpty ? '${_doctorWalletBalanceKey}_$name' : _doctorWalletBalanceKey;
    return prefs.getDouble(key) ?? 0.0;
  }

  Future<void> saveDoctorWalletBalance(double balance, {String? doctorName}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final name = doctorName ?? await getName();
    final key = name != null && name.isNotEmpty ? '${_doctorWalletBalanceKey}_$name' : _doctorWalletBalanceKey;
    await prefs.setDouble(key, balance);
  }

  Future<void> addToDoctorWalletBalance(double amount, {String? doctorName}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final name = doctorName ?? await getName();
    final key = name != null && name.isNotEmpty ? '${_doctorWalletBalanceKey}_$name' : _doctorWalletBalanceKey;
    final double currentBalance = prefs.getDouble(key) ?? 0.0;
    await prefs.setDouble(key, currentBalance + amount);
  }

  Future<List<String>> getDoctorWalletTransactions({String? doctorName}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final name = doctorName ?? await getName();
    final key = name != null && name.isNotEmpty ? '${_doctorWalletTransactionsKey}_$name' : _doctorWalletTransactionsKey;
    return prefs.getStringList(key) ?? [];
  }

  Future<void> addDoctorWalletTransaction({
    required int appointmentId,
    required String patientName,
    required double amount,
    required String date,
    String? doctorName,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final name = doctorName ?? await getName();
    final key = name != null && name.isNotEmpty ? '${_doctorWalletTransactionsKey}_$name' : _doctorWalletTransactionsKey;
    final List<String> currentTx = prefs.getStringList(key) ?? [];
    final String txJson =
        '{"appointmentId": $appointmentId, "patientName": "$patientName", "amount": $amount, "date": "$date"}';
    currentTx.insert(0, txJson); // Insert at the top to show latest first
    await prefs.setStringList(key, currentTx);
  }

  Future<void> saveClinicLocalData(
    int clinicId,
    String duration,
    String notes,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('clinic_${clinicId}_duration', duration);
    await prefs.setString('clinic_${clinicId}_notes', notes);
  }

  Future<Map<String, String>> getClinicLocalData(int clinicId) async {
    final prefs = await SharedPreferences.getInstance();
    final duration =
        prefs.getString('clinic_${clinicId}_duration') ?? '30 mins';
    final notes = prefs.getString('clinic_${clinicId}_notes') ?? '';
    return {'duration': duration, 'notes': notes};
  }

  // --- Patient Health Metrics ---
  static const String _healthMetricsHistoryKey = 'patient_health_metrics_history';

  Future<void> addHealthMetricRecord(Map<String, dynamic> record) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = List<String>.from(prefs.getStringList(_healthMetricsHistoryKey) ?? []);
    
    // Add the new record as a JSON string at the beginning
    // We assume 'dart:convert' is available, but if not we can build simple json string.
    // It's safer to use dart:convert. Wait, I should add the import if needed.
    // I will use a simple string serialization or import dart:convert at the top.
    
    final recordStr = '{"heartRate": "${record['heartRate']}", "bloodPressure": "${record['bloodPressure']}", "bloodSugar": "${record['bloodSugar']}", "weight": "${record['weight']}", "notes": "${record['notes']}", "timestamp": "${record['timestamp']}"}';
    
    history.insert(0, recordStr);
    await prefs.setStringList(_healthMetricsHistoryKey, history);
  }

  Future<List<String>> getHealthMetricsHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_healthMetricsHistoryKey) ?? [];
  }

  Future<Map<String, String>> getHealthMetrics() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_healthMetricsHistoryKey) ?? [];
    
    if (history.isNotEmpty) {
      final latest = history.first;
      // manual parsing for simplicity if dart:convert is not imported
      final hrMatch = RegExp(r'"heartRate":\s*"([^"]+)"').firstMatch(latest);
      final bpMatch = RegExp(r'"bloodPressure":\s*"([^"]+)"').firstMatch(latest);
      
      final hr = hrMatch?.group(1) ?? '72';
      final bp = bpMatch?.group(1) ?? '120/80';
      return {'heartRate': hr, 'bloodPressure': bp};
    }
    
    return {'heartRate': '72', 'bloodPressure': '120/80'};
  }

  static const String _medicationsKey = 'patient_medications';

  Future<void> saveMedications(List<Map<String, dynamic>> medications) async {
    final prefs = await SharedPreferences.getInstance();
    // Convert list of maps to list of JSON strings for simple storage
    final List<String> medsStr = medications.map((m) {
      return '{"title": "${m['title']}", "subtitle": "${m['subtitle']}", "badge": "${m['badge']}"}';
    }).toList();
    await prefs.setStringList(_medicationsKey, medsStr);
  }

  Future<List<Map<String, dynamic>>> getMedications() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> medsStr = prefs.getStringList(_medicationsKey) ?? [];
    if (medsStr.isEmpty) return [];

    return medsStr.map((s) {
      final titleMatch = RegExp(r'"title":\s*"([^"]+)"').firstMatch(s);
      final subtitleMatch = RegExp(r'"subtitle":\s*"([^"]+)"').firstMatch(s);
      final badgeMatch = RegExp(r'"badge":\s*"([^"]+)"').firstMatch(s);
      return {
        'title': titleMatch?.group(1) ?? '',
        'subtitle': subtitleMatch?.group(1) ?? '',
        'badge': badgeMatch?.group(1) ?? '',
      };
    }).toList();
  }

  // --- Lock Status for Doctors & Patients ---
  // Key pattern: 'lock_status_doctor_{id}' or 'lock_status_patient_{id}'

  Future<void> saveDoctorLockStatus(String doctorId, bool isLocked) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('lock_status_doctor_$doctorId', isLocked);
  }

  Future<bool?> getDoctorLockStatus(String doctorId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('lock_status_doctor_$doctorId');
  }

  Future<void> savePatientLockStatus(String patientId, bool isLocked) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('lock_status_patient_$patientId', isLocked);
  }

  Future<bool?> getPatientLockStatus(String patientId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('lock_status_patient_$patientId');
  }
}
