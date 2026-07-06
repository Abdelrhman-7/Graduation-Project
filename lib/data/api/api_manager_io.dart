// IO-specific implementation (Android, iOS, Desktop, Windows).
import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:path_provider/path_provider.dart';

/// On IO platforms: returns a [PersistCookieJar] backed by the file system,
/// and configures the Dio adapter to accept bad SSL certificates.
/// NOTE: CookieManager is intentionally NOT added here — it is added
/// in api_manager.dart AFTER the secure-flag removal interceptor so
/// that cookies are stored without the Secure flag and can be sent over HTTP.
Future<CookieJar> createCookieJar(Dio dio) async {
  // Fix SSL + Force HTTP/1.1
  final adapter = dio.httpClientAdapter;
  if (adapter is IOHttpClientAdapter) {
    adapter.createHttpClient = () {
      final client = HttpClient()
        ..badCertificateCallback = (cert, host, port) => true;
      client.userAgent = 'Dart/3.0 (dart:io)';
      return client;
    };
  }

  // Setup PersistCookieJar with file-based storage
  final dir = await getApplicationDocumentsDirectory();
  final cookieJar = PersistCookieJar(
    ignoreExpires: true,
    storage: FileStorage('${dir.path}/.cookies/'),
  );
  // CookieManager added by caller (api_manager.dart) after secure interceptor
  return cookieJar;
}
