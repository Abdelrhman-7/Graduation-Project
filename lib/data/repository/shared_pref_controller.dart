import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefController {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _tokenKey = 'auth_token';
  static const String _emailKey = 'user_email';
  static const String _nameKey = 'user_name';
  static const String _imageKey = 'user_image';

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
}

