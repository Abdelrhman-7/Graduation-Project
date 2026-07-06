// Web-specific implementation: no dart:io, no file system cookies.
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

/// On Web: returns an in-memory [CookieJar] (no file storage available).
/// NOTE: CookieManager is intentionally NOT added here — it is added
/// in api_manager.dart AFTER the secure-flag removal interceptor so
/// that cookies are stored without the Secure flag.
Future<CookieJar> createCookieJar(Dio dio) async {
  final cookieJar = CookieJar();
  // CookieManager added by caller (api_manager.dart) after secure interceptor
  return cookieJar;
}
