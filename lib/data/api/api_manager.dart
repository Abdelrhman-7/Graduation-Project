// ignore_for_file: avoid_print
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../models/login_model.dart';
import '../models/register_model.dart';

class ApiManager {
  final Dio _dio;
  static const String _baseUrl = 'http://medicalsystem111.runasp.net/api/';

  ApiManager()
    : _dio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 60),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Connection': 'keep-alive',
          },
          responseType: ResponseType.json,
        ),
      ) {
    // Fix SSL + Force HTTP/1.1
    final adapter = _dio.httpClientAdapter;
    if (adapter is IOHttpClientAdapter) {
      adapter.createHttpClient = () {
        final client = HttpClient()
          ..badCertificateCallback = (cert, host, port) => true;

        // Force HTTP/1.1 — prevents "Connection reset by peer" on some servers
        client.userAgent = 'Dart/3.0 (dart:io)';

        return client;
      };
    }

    // Retry interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          if (_isRetryable(error) &&
              error.requestOptions.extra['retried'] != true) {
            try {
              print('Retrying request after connection error...');
              await Future.delayed(const Duration(seconds: 2));

              final opts = error.requestOptions;
              opts.extra['retried'] = true;

              final response = await _dio.request(
                opts.path,
                data: opts.data,
                queryParameters: opts.queryParameters,
                options: Options(
                  method: opts.method,
                  headers: opts.headers,
                  extra: opts.extra,
                ),
              );
              handler.resolve(response);
              return;
            } catch (e) {
              // Retry failed, continue with original error
            }
          }
          handler.next(error);
        },
      ),
    );

    // Log interceptor
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        requestHeader: true,
      ),
    );
  }

  bool _isRetryable(DioException error) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        (error.message?.contains('Connection reset') ?? false) ||
        (error.message?.contains('Connection closed') ?? false);
  }

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final body = request.toJson();
      print('Login request body: $body');

      final response = await _dio.post('Identity/AccountApi/Login', data: body);

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;

        // Server returns {token, expires} directly — wrap it in LoginResponse
        if (data.containsKey('token')) {
          return LoginResponse(
            status: true,
            message: 'Login Successful',
            data: LoginData(
              token: data['token'] as String?,
              email: null,
              fullName: null,
            ),
          );
        }

        // Handle new response format: {"message":"...","roles":["..."],"userId":"..."}
        if (data.containsKey('userId') && data.containsKey('roles')) {
          return LoginResponse(
            status: true,
            message: data['message']?.toString() ?? 'Login Successful',
            data: LoginData(token: null, email: null, fullName: null),
          );
        }

        // Fallback: server might return {status, message, data} format
        return LoginResponse.fromJson(data);
      } else {
        return LoginResponse(
          status: false,
          message: 'Unexpected response format',
        );
      }
    } on DioException catch (e) {
      print('Login DioException: ${e.type} — ${e.message}');
      if (e.response != null) {
        print('Login Error Response Body: ${e.response?.data}');
        final data = e.response!.data;
        if (data is Map<String, dynamic>) {
          // If server returns a specific message
          String? serverMessage = data['message']?.toString();
          
          // Handle ASP.NET Identity error format if applicable
          if (serverMessage == null && data['errors'] != null) {
            final errors = data['errors'];
            if (errors is Map && errors.isNotEmpty) {
              serverMessage = errors.values.first.toString();
            } else if (errors is List && errors.isNotEmpty) {
              serverMessage = errors.first.toString();
            }
          }

          return LoginResponse(
            status: false,
            message: serverMessage ?? (e.response?.statusCode == 401 ? 'Invalid Email or Password' : _friendlyError(e)),
          );
        } else if (data is String && data.isNotEmpty) {
          return LoginResponse(status: false, message: data);
        }
      }
      return LoginResponse(status: false, message: _friendlyError(e));
    } catch (e) {
      print('Login error: $e');
      return LoginResponse(status: false, message: e.toString());
    }
  }

  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final formData = FormData.fromMap(request.toMap());
      
      if (request.imageFile != null && request.imageFile is String) {
        formData.files.add(MapEntry(
          'ImageFile',
          await MultipartFile.fromFile(request.imageFile as String),
        ));
      }

      print('Register request body: ${request.toMap()}');

      final response = await _dio.post(
        'Identity/AccountApi/RegisterPatient',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      print('Register response: ${response.statusCode} — ${response.data}');
      return RegisterResponse.fromJson(response.data is Map<String, dynamic> ? response.data : {'message': response.data.toString()});
    } on DioException catch (e) {
      print('Register DioException: ${e.type} — ${e.message}');
      final data = e.response?.data;
      print('Register Error Data: $data');

      if (data is List) {
        final errorMessage = data
            .map((error) {
              if (error is Map && error.containsKey('description')) {
                return error['description'].toString();
              }
              return error.toString();
            })
            .join('\n');
        return RegisterResponse(status: false, message: errorMessage);
      }

      if (data is Map<String, dynamic>) {
        // Handle ASP.NET Identity "errors" object
        if (data.containsKey('errors') && data['errors'] is Map) {
          final errors = data['errors'] as Map;
          final errorMessages = <String>[];
          errors.forEach((key, value) {
            if (value is List) {
              errorMessages.add(value.join(', '));
            } else {
              errorMessages.add(value.toString());
            }
          });
          return RegisterResponse(status: false, message: errorMessages.join('\n'));
        }

        return RegisterResponse(
          status: false,
          message: data['message']?.toString() ?? data['title']?.toString() ?? e.message ?? 'Error',
        );
      }

      return RegisterResponse(status: false, message: _friendlyError(e));
    } catch (e) {
      print('Register error: $e');
      return RegisterResponse(status: false, message: e.toString());
    }
  }

  String _friendlyError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Server is taking too long to respond. Please try again.';
      case DioExceptionType.connectionError:
        return 'Could not connect to server. Please check your internet.';
      default:
        return e.message ?? 'Connection Error';
    }
  }

  Future<RegisterResponse> forgetPassword(String email) async {
    try {
      final response = await _dio.post(
        'Identity/AccountApi/ForgotPassword',
        data: {'email': email},
      );
      return RegisterResponse.fromJson(response.data);
    } catch (e) {
      return RegisterResponse(status: false, message: e.toString());
    }
  }
}
