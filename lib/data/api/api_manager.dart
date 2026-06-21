// ignore_for_file: avoid_print
import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:graduationproject/data/models/schudule/cliniceSchedual.dart';
import 'package:graduationproject/data/models/schudule/creatSchudel.dart';
import 'package:graduationproject/data/models/schudule/doctorModel.dart';
import '../models/Auth/login_model.dart';
import '../models/Auth/register_model.dart';
import '../models/Auth/logout_model.dart';
import '../repository/shared_pref_controller.dart';

class ApiManager {
  final Dio _dio;
  final PersistCookieJar _cookieJar;
  static const String _baseUrl = 'http://medicalsystem111.runasp.net/api/';

  ApiManager._internal(this._dio, this._cookieJar);

  /// Call this factory to create an ApiManager with fully initialized cookies.
  static Future<ApiManager> create() async {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(minutes: 3),
        sendTimeout: const Duration(minutes: 3),
        headers: {'Accept': 'application/json', 'Connection': 'keep-alive'},
        responseType: ResponseType.json,
        followRedirects: false,
        validateStatus: (status) => status != null && status < 400,
      ),
    );

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

    // Setup PersistCookieJar
    final dir = await getApplicationDocumentsDirectory();
    final cookieJar = PersistCookieJar(
      ignoreExpires: true,
      storage: FileStorage('${dir.path}/.cookies/'),
    );

    // Strip secure flag from cookies so they can be sent over HTTP
    dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          final setCookies = response.headers['set-cookie'];
          if (setCookies != null && setCookies.isNotEmpty) {
            final modifiedCookies = setCookies.map((cookie) {
              return cookie.replaceAll(
                RegExp(r';\s*secure', caseSensitive: false),
                '',
              );
            }).toList();
            response.headers.set('set-cookie', modifiedCookies);
          }
          return handler.next(response);
        },
      ),
    );

    dio.interceptors.add(CookieManager(cookieJar));

    // Retry interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          if ((error.type == DioExceptionType.connectionError ||
                  error.type == DioExceptionType.connectionTimeout ||
                  error.type == DioExceptionType.receiveTimeout ||
                  (error.message?.contains('Connection reset') ?? false)) &&
              error.requestOptions.extra['retried'] != true) {
            try {
              print('Retrying request after connection error...');
              await Future.delayed(const Duration(seconds: 2));
              final opts = error.requestOptions;
              opts.extra['retried'] = true;
              final response = await dio.request(
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
            } catch (retryError) {
              if (retryError is DioException) {
                handler.next(retryError);
              } else {
                handler.next(error);
              }
              return;
            }
          }
          handler.next(error);
        },
      ),
    );

    // Log interceptor
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        requestHeader: true,
      ),
    );

    // Auth interceptor (JWT Token)
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = SharedPrefController();
          final token = await prefs.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );

    return ApiManager._internal(dio, cookieJar);
  }

  PersistCookieJar get cookieJar => _cookieJar;

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
            message:
                serverMessage ??
                (e.response?.statusCode == 401
                    ? 'Invalid Email or Password'
                    : _friendlyError(e)),
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

  Future<RegisterResponse> register({
    required RegisterRequest request,
    required bool isDoctor,
  }) async {
    try {
      final formData = FormData.fromMap(request.toMap(isDoctor: isDoctor));

      // Image
      if (request.imageFile != null && request.imageFile is String) {
        formData.files.add(
          MapEntry(
            'ImageFile',
            await MultipartFile.fromFile(request.imageFile!),
          ),
        );
      }

      print(
        'Register request body: '
        '${request.toMap(isDoctor: isDoctor)}',
      );

      final response = await _dio.post(
        isDoctor
            ? 'Identity/AccountApi/RegisterDoctor'
            : 'Identity/AccountApi/RegisterPatient',

        data: formData,

        options: Options(contentType: 'multipart/form-data'),
      );

      print(
        'Register response: '
        '${response.statusCode} — ${response.data}',
      );

      return RegisterResponse.fromJson(
        response.data is Map<String, dynamic>
            ? response.data
            : {'message': response.data.toString()},
      );
    } on DioException catch (e) {
      print(
        'Register DioException: '
        '${e.type} — ${e.message}',
      );

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

          return RegisterResponse(
            status: false,
            message: errorMessages.join('\n'),
          );
        }

        return RegisterResponse(
          status: false,
          message:
              data['message']?.toString() ??
              data['title']?.toString() ??
              e.message ??
              'Error',
        );
      }

      return RegisterResponse(status: false, message: _friendlyError(e));
    } catch (e) {
      print('Register error: $e');

      return RegisterResponse(status: false, message: e.toString());
    }
  }

  /// ********************************
  Future<RegisterResponse> doctorRegister(RegisterRequest request) async {
    try {
      final formData = FormData.fromMap({
        'FullName': request.fullName,
        'UserName': request.userName,
        'Email': request.email,
        'Password': request.password,
        'PhoneNumber': request.phoneNumber,
        'Address': request.address,
        'Gender': request.gender,
        'DateOfBirth': request.dateOfBirth,
        'DepartmentId': request.departmentId,
        'AboutMe': request.aboutMe,
      });

      if (request.imageFile != null && request.imageFile is String) {
        formData.files.add(
          MapEntry(
            'ImageFile',
            await MultipartFile.fromFile(request.imageFile as String),
          ),
        );
      }

      final response = await _dio.post(
        'Identity/AccountApi/RegisterDoctor',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return RegisterResponse.fromJson(response.data);
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map) {
        return RegisterResponse(status: false, message: data['message']);
      }
      return RegisterResponse(status: false, message: 'Registration failed');
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
      return RegisterResponse.fromJson(
        response.data is Map<String, dynamic>
            ? response.data
            : {'message': response.data.toString()},
      );
    } catch (e) {
      return RegisterResponse(status: false, message: e.toString());
    }
  }

  Future<LogoutResponse> logout() async {
    try {
      final response = await _dio.post('Identity/AccountApi/Logout');
      if (response.statusCode == 200) {
        return LogoutResponse(status: true, message: 'Logout Successful');
      }
      return LogoutResponse(status: false, message: 'Logout failed');
    } catch (e) {
      return LogoutResponse(status: true, message: 'Logout Successful');
    }
  }

  Future<bool> chooseRole(String role) async {
    try {
      final response = await _dio.get(
        'Identity/AccountApi/ChooseRole',
        queryParameters: {'role': role},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('ChooseRole error: $e');
      return false;
    }
  }

  // جلب كل العيادات الخاصة بالطبيب
  Future<List<ClinicModel>> getDoctorClinics() async {
    try {
      final response = await _dio.get(
        'Doctor/ClinicApi/GetAllClinics',
        queryParameters: {'currentPage': 1},
      );

      // ====== DEBUG: اطبع الـ response كامل عشان نعرف شكل الداتا ======
      print('===== GetAllClinics RAW RESPONSE =====');
      print('Status: ${response.statusCode}');
      print('Data Type: ${response.data.runtimeType}');
      print('Data: ${response.data}');
      print('======================================');

      // إذا كان السيرفر بيرجع لستة مباشرة
      if (response.data is List) {
        final list = response.data as List;
        for (var i = 0; i < list.length; i++) {
          print(
            'Clinic[$i] keys: ${list[i] is Map ? (list[i] as Map).keys.toList() : "NOT A MAP"}',
          );
        }
        return list.map((json) => ClinicModel.fromJson(json)).toList();
      }
      // بناءً على الـ JSON اللي إنت بعته، السيرفر بيرجع Map وفيها مفتاح 'clinics'
      else if (response.data is Map<String, dynamic>) {
        print('Response Map keys: ${(response.data as Map).keys.toList()}');
        // جرّب كل المفاتيح المحتملة
        final map = response.data as Map<String, dynamic>;
        List? list;
        for (final key in ['clinics', 'data', 'items', 'result', 'Clinics']) {
          if (map[key] is List) {
            list = map[key] as List;
            print('Found clinics under key: "$key"');
            break;
          }
        }
        if (list != null) {
          for (var i = 0; i < list.length; i++) {
            print(
              'Clinic[$i] keys: ${list[i] is Map ? (list[i] as Map).keys.toList() : "NOT A MAP"}',
            );
          }
          return list.map((json) => ClinicModel.fromJson(json)).toList();
        }

        // Fallback: If the API accidentally returns a single clinic object instead of a list
        if (map.containsKey('id') && map.containsKey('name')) {
          print(
            'GetAllClinics returned a single clinic object! Wrapping in list.',
          );
          return [ClinicModel.fromJson(map)];
        }
      }
      throw 'Unknown GetAllClinics response format: ${(response.data as Map).keys.toList()}';
    } catch (e) {
      print('Failed to get clinics: $e');
      throw 'Failed to load clinics: $e';
    }
  }

  Future<bool> createSchedule(CreateScheduleModel schedule) async {
    try {
      // تحويل الـ ClinicId لرقم لأن السيرفر غالباً بيطلبه int
      final int? clinicIdInt = schedule.clinicId;

      final formData = FormData.fromMap({
        'DayOfWeek': schedule.day, // تغيير المفتاح بناءً على طلبك
        'StartTime': schedule.startTime,
        'EndTime': schedule.endTime,
        'ClinicId': clinicIdInt,
      });

      print(
        'Sending CreateSchedule with: Day=${schedule.day}, Start=${schedule.startTime}, End=${schedule.endTime}, ClinicId=$clinicIdInt',
      );

      final response = await _dio.post(
        'Doctor/ScheduleApi/CreateSchedule',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          validateStatus: (status) => true, // عشان نشوف الـ Response حتى لو 400
        ),
      );

      print(
        'CreateSchedule Response: ${response.statusCode} - ${response.data}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        // استخراج رسالة الخطأ من السيرفر (مثلاً: A schedule with overlapping time already exists)
        String errorMessage = 'Failed to create schedule';
        if (response.data is Map<String, dynamic> &&
            response.data.containsKey('message')) {
          errorMessage = response.data['message'];
        } else if (response.data is String) {
          errorMessage = response.data;
        }

        print('Server Error Message: $errorMessage');
        throw errorMessage; // نرفع الخطأ عشان الـ Cubit يمسكه ويعرضه
      }
    } catch (e) {
      print('Failed to create schedule: $e');
      rethrow; // إعادة رفع الخطأ
    }
  }

  Future<bool> addClinic(ClinicModel clinic) async {
    try {
      final formData = FormData.fromMap(clinic.toJson());

      final response = await _dio.post(
        'Doctor/ClinicApi/CreateClinic',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          validateStatus: (status) => true,
        ),
      );

      print('Add Clinic Response: ${response.statusCode} - ${response.data}');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Failed to add clinic: $e');
      return false;
    }
  }

  Future<bool> updateClinic(ClinicModel clinic) async {
    try {
      final formData = FormData.fromMap({'Id': clinic.id, ...clinic.toJson()});

      final response = await _dio.put(
        'Doctor/ClinicApi/EditClinic/${clinic.id}',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          validateStatus: (status) => true,
        ),
      );

      print('Edit Clinic Response: ${response.statusCode} - ${response.data}');

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Failed to update clinic: $e');
      return false;
    }
  }

  Future<List<dynamic>> getClinicBookings(int clinicId) async {
    try {
      final response = await _dio.get(
        'Doctor/ScheduleApi/GetClinicBookings',
        queryParameters: {'clinicId': clinicId},
      );
      if (response.data is List) {
        return response.data as List;
      }
      return [];
    } catch (e) {
      print('Failed to get clinic bookings: $e');
      return [];
    }
  }

  Future<List<dynamic>> getAllSchedules() async {
    try {
      final response = await _dio.get(
        'Doctor/ScheduleApi/GetAllSchedules',
        queryParameters: {'currentPage': 1},
        options: Options(validateStatus: (status) => true),
      );
      print(
        '=== GetAllSchedules Response: ${response.statusCode} - ${response.data} ===',
      );

      if (response.statusCode != 200) {
        return [];
      }

      if (response.data is List) {
        return response.data as List;
      }

      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        for (final key in [
          'schedules',
          'data',
          'items',
          'result',
          'Schedules',
          'Items',
        ]) {
          if (map[key] is List) return map[key] as List;
        }
      }
      return [];
    } catch (e) {
      print('Failed to get all schedules: $e');
      return [];
    }
  }

  Future<bool> editSchedule(editClinicModel clinic) async {
    try {
      final mapData = <String, dynamic>{};
      if (clinic.clinicId != null && clinic.clinicId!.isNotEmpty) {
        mapData['ClinicId'] = int.tryParse(clinic.clinicId!);
      }
      if (clinic.day != null && clinic.day!.isNotEmpty) {
        mapData['DayOfWeek'] = clinic.day;
      }
      if (clinic.startTime != null && clinic.startTime!.isNotEmpty) {
        mapData['StartTime'] = clinic.startTime;
      }
      if (clinic.endTime != null && clinic.endTime!.isNotEmpty) {
        mapData['EndTime'] = clinic.endTime;
      }
      if (clinic.appointmentDuration != null &&
          clinic.appointmentDuration!.isNotEmpty) {
        mapData['AppointmentDuration'] = int.tryParse(
          clinic.appointmentDuration!,
        );
      }
      if (clinic.nots != null && clinic.nots!.isNotEmpty) {
        mapData['Notes'] = clinic.nots;
      }

      print('Sending EditSchedule data: $mapData');

      final response = await _dio.put(
        'Doctor/ScheduleApi/EditSchedule/${clinic.id}',
        data: FormData.fromMap(mapData),
        options: Options(validateStatus: (status) => true),
      );

      print('EditSchedule Response: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        String errorMessage = 'Failed to edit schedule';
        if (response.data is Map<String, dynamic>) {
          if (response.data.containsKey('message')) {
            errorMessage = response.data['message'];
          } else if (response.data.containsKey('errors')) {
            errorMessage = response.data['errors'].toString();
          } else {
            errorMessage = response.data.toString();
          }
        } else if (response.data != null &&
            response.data.toString().isNotEmpty) {
          errorMessage = response.data.toString();
        }
        throw errorMessage;
      }
    } catch (e) {
      print('Failed to edit schedule: $e');
      throw e.toString();
    }
  }

  Future<bool> deleteSchedule(int scheduleId) async {
    try {
      final response = await _dio.delete(
        'Doctor/ScheduleApi/DeleteSchedule/$scheduleId',
        options: Options(validateStatus: (status) => true),
      );
      print(
        'DeleteSchedule[$scheduleId]: ${response.statusCode} - ${response.data}',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        String errorMessage = 'Failed to delete schedule';
        if (response.data is Map<String, dynamic> &&
            response.data.containsKey('message')) {
          errorMessage = response.data['message'];
        } else if (response.data is String) {
          errorMessage = response.data;
        }
        throw errorMessage;
      }
    } catch (e) {
      print('Failed to delete schedule: $e');
      throw e.toString();
    }
  }

  Future<List<dynamic>> getClinicSchedules(int clinicId) async {
    return getPatientClinicSchedules(clinicId: clinicId);
  }

  /// جلب مواعيد عيادة معينة باستخدام Patient endpoint
  Future<List<dynamic>> getPatientClinicSchedules({
    required int clinicId,
    int? doctorId,
  }) async {
    try {
      final queryParams = <String, dynamic>{'clinicId': clinicId};
      if (doctorId != null) queryParams['doctorId'] = doctorId;

      final response = await _dio.get(
        'Patient/AppointmentApi/GetClinicSchedules',
        queryParameters: queryParams,
        options: Options(validateStatus: (status) => true),
      );
      print(
        'GetClinicSchedules[clinic=$clinicId, doctor=$doctorId]: ${response.statusCode} - ${response.data}',
      );

      if (response.statusCode == 302 || response.statusCode == 404) {
        return [];
      }

      if (response.statusCode != 200) {
        return [];
      }

      if (response.data is List) {
        return response.data as List<dynamic>;
      }

      if (response.data is Map) {
        final map = response.data as Map<String, dynamic>;
        for (final key in [
          'schedules',
          'Schedules',
          'data',
          'Data',
          'items',
          'Items',
          'result',
          'Result',
          r'$values',
        ]) {
          if (map[key] is List) return map[key] as List<dynamic>;
        }
        for (final value in map.values) {
          if (value is List) return value as List<dynamic>;
        }
      }

      return [];
    } catch (e) {
      print('Failed to get clinic schedules: $e');
      return [];
    }
  }

  Future<bool> deleteClinic(int id) async {
    try {
      final response = await _dio.delete(
        'Doctor/ClinicApi/DeleteClinic/$id',
        queryParameters: {'id': id},
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Failed to delete clinic: $e');
      return false;
    }
  }

  // ============================================================
  // Patient APIs
  // ============================================================

  /// جلب كل الأطباء للباشنت
  Future<List<DoctorModel>> getPatientDoctors() async {
    try {
      final response = await _dio.get(
        'Patient/AppointmentApi/GetAllDoctors',
        queryParameters: {'currentPage': 1},
        options: Options(validateStatus: (status) => true),
      );

      print('Patient GetAllDoctors status: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> items = [];
        if (response.data is List) {
          items = response.data as List;
        } else if (response.data is Map<String, dynamic>) {
          final map = response.data as Map<String, dynamic>;
          for (final key in ['doctors', 'items', 'data', 'result', 'Doctors']) {
            if (map[key] is List) {
              items = map[key] as List;
              break;
            }
          }
        }
        return items.map((json) => DoctorModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Failed to get patient doctors: $e');
      return [];
    }
  }

  /// جلب تفاصيل طبيب معين للباشنت
  Future<DoctorModel?> getPatientDoctorDetails(int doctorId) async {
    try {
      final response = await _dio.get(
        'Patient/AppointmentApi/GetDoctor/$doctorId',
        options: Options(validateStatus: (status) => true),
      );

      print('Patient GetDoctorDetails status: ${response.statusCode}');
      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return DoctorModel.fromJson(response.data as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      print('Failed to get patient doctor details: $e');
      return null;
    }
  }

  /// جلب عيادات طبيب معين للباشنت
  Future<List<ClinicModel>> getPatientDoctorClinics(int doctorId) async {
    try {
      final response = await _dio.get(
        'Patient/AppointmentApi/GetDoctorClinics/$doctorId',
        queryParameters: {'currentPage': 1},
        options: Options(validateStatus: (status) => true),
      );

      print('Patient GetDoctorClinics status: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> items = [];
        if (response.data is List) {
          items = response.data as List;
        } else if (response.data is Map<String, dynamic>) {
          final map = response.data as Map<String, dynamic>;
          for (final key in ['clinics', 'items', 'data', 'result', 'Clinics']) {
            if (map[key] is List) {
              items = map[key] as List;
              break;
            }
          }
          if (items.isEmpty && map.containsKey('id') && map.containsKey('name')) {
            // is a single clinic object
            return [ClinicModel.fromJson(map)];
          }
        }
        return items.map((json) => ClinicModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Failed to get patient doctor clinics: $e');
      return [];
    }
  }

  /// حجز موعد
  Future<bool> bookPatientAppointment({
    required int scheduleId,
    required String reasonForVisit,
    required String paymentMethod,
  }) async {
    try {
      final formData = FormData.fromMap({
        'ScheduleId': scheduleId,
        'ReasonForVisit': reasonForVisit,
        'PaymentMethod': paymentMethod,
      });

      print('Booking patient appointment with data: ScheduleId: $scheduleId, Reason: $reasonForVisit, PaymentMethod: $paymentMethod');

      final response = await _dio.post(
        'Patient/AppointmentApi/BookAppointment',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          validateStatus: (status) => true,
          sendTimeout: const Duration(minutes: 10),
          receiveTimeout: const Duration(minutes: 10),
        ),
      );

      print('BookPatientAppointment Response: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        String errorMessage = 'Failed to book appointment';
        if (response.data is Map<String, dynamic> && response.data.containsKey('message')) {
          errorMessage = response.data['message'];
        } else if (response.data is String) {
          errorMessage = response.data;
        }
        throw errorMessage;
      }
    } catch (e) {
      print('Failed to book patient appointment: $e');
      rethrow;
    }
  }

  /// جلب كل العيادات المتاحة للباشنت مع بيانات الطبيب
  Future<List<ClinicModel>> getPatientAllClinics() async {
    try {
      final response = await _dio.get(
        'Patient/AppointmentApi/GetAllDoctors',
        queryParameters: {'currentPage': 1},
        options: Options(validateStatus: (status) => true),
      );

      print(
        '===== Patient GetAllPatientDoctors [Patient/AppointmentApi/GetAllDoctors] =====',
      );
      print('Status: ${response.statusCode}');
      print('Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> items = [];
        if (response.data is List) {
          items = response.data as List;
        } else if (response.data is Map<String, dynamic>) {
          final map = response.data as Map<String, dynamic>;
          for (final key in [
            'doctors',
            'clinics',
            'data',
            'items',
            'result',
            'Clinics',
            'Doctors',
          ]) {
            if (map[key] is List) {
              items = map[key] as List;
              break;
            }
          }
        }

        List<ClinicModel> allClinics = [];
        for (var item in items) {
          if (item is Map<String, dynamic>) {
            bool hasClinics = false;
            // 1. If clinics are nested inside the doctor object
            for (var key in ['clinics', 'doctorClinics', 'Clinics']) {
              if (item[key] is List && (item[key] as List).isNotEmpty) {
                hasClinics = true;
                for (var c in item[key]) {
                  if (c is Map<String, dynamic>) {
                    c['doctorFullName'] = item['fullName'] ?? item['name'];
                    c['doctorSpecialty'] =
                        item['specialty'] ?? item['department'] ?? item['departmentName'];
                    c['doctorImageUrl'] =
                        item['imageUrl'] ?? item['profileImageUrl'] ?? item['displayImageUrl'];

                    // Fetch schedules if missing
                    if (c['clinicSchedules'] == null &&
                        c['schedules'] == null &&
                        c['id'] != null) {
                      try {
                        final schedRes = await _dio.get(
                          'Patient/AppointmentApi/GetClinicSchedules',
                          queryParameters: {
                            'doctorId': item['id'],
                            'clinicId': c['id'],
                          },
                          options: Options(validateStatus: (s) => true),
                        );
                        print(
                          '=== SCHEDULE RESPONSE [clinic=${c["id"]}] status=${schedRes.statusCode} data=${schedRes.data} ===',
                        );
                        if (schedRes.statusCode == 200) {
                          if (schedRes.data is List) {
                            c['clinicSchedules'] = schedRes.data;
                          } else if (schedRes.data is Map) {
                            final sm = schedRes.data as Map;
                            for (final k in [
                              'items',
                              'data',
                              'schedules',
                              'clinicSchedules',
                              'Schedules',
                              'Items',
                            ]) {
                              if (sm[k] is List) {
                                c['clinicSchedules'] = sm[k];
                                break;
                              }
                            }
                            // fallback: first list value
                            if (c['clinicSchedules'] == null) {
                              for (final v in sm.values) {
                                if (v is List) {
                                  c['clinicSchedules'] = v;
                                  break;
                                }
                              }
                            }
                          }
                        }
                      } catch (e) {
                        print('Schedule fetch error: $e');
                      }
                    }

                    allClinics.add(ClinicModel.fromJson(c));
                  }
                }
                break;
              }
            }

            // 2. If it's a doctor without clinics nested, fetch them individually
            if (!hasClinics &&
                !item.containsKey('consultationPrice') &&
                item.containsKey('id')) {
              try {
                final docId = item['id'];
                final clinicsRes = await _dio.get(
                  'Patient/AppointmentApi/GetDoctorClinics/$docId',
                  options: Options(validateStatus: (s) => true),
                );
                if (clinicsRes.statusCode == 200) {
                  List<dynamic> docClinics = [];
                  if (clinicsRes.data is List)
                    docClinics = clinicsRes.data;
                  else if (clinicsRes.data is Map &&
                      clinicsRes.data['clinics'] is List)
                    docClinics = clinicsRes.data['clinics'];

                  if (docClinics.isNotEmpty) {
                    hasClinics = true;
                    for (var c in docClinics) {
                      if (c is Map<String, dynamic>) {
                        c['doctorFullName'] = item['fullName'] ?? item['name'];
                        c['doctorSpecialty'] =
                            item['specialty'] ?? item['department'] ?? item['departmentName'];
                        c['doctorImageUrl'] =
                            item['imageUrl'] ?? item['profileImageUrl'] ?? item['displayImageUrl'];

                        // Fetch schedules if missing
                        if (c['clinicSchedules'] == null &&
                            c['schedules'] == null &&
                            c['id'] != null) {
                          try {
                            final schedRes = await _dio.get(
                              'Patient/AppointmentApi/GetClinicSchedules',
                              queryParameters: {
                                'doctorId': docId,
                                'clinicId': c['id'],
                              },
                              options: Options(validateStatus: (s) => true),
                            );
                            print(
                              '=== SCHEDULE RESPONSE [clinic=${c["id"]}] status=${schedRes.statusCode} data=${schedRes.data} ===',
                            );
                            if (schedRes.statusCode == 200) {
                              if (schedRes.data is List) {
                                c['clinicSchedules'] = schedRes.data;
                              } else if (schedRes.data is Map) {
                                final sm = schedRes.data as Map;
                                for (final k in [
                                  'items',
                                  'data',
                                  'schedules',
                                  'clinicSchedules',
                                  'Schedules',
                                  'Items',
                                ]) {
                                  if (sm[k] is List) {
                                    c['clinicSchedules'] = sm[k];
                                    break;
                                  }
                                }
                                if (c['clinicSchedules'] == null) {
                                  for (final v in sm.values) {
                                    if (v is List) {
                                      c['clinicSchedules'] = v;
                                      break;
                                    }
                                  }
                                }
                              }
                            }
                          } catch (e) {
                            print('Schedule fetch error: $e');
                          }
                        }

                        allClinics.add(ClinicModel.fromJson(c));
                      }
                    }
                  }
                }
              } catch (e) {
                print('Failed to get clinics for doctor ${item['id']}: $e');
              }
            }

            // 3. Fallback if no clinics found or it is already a clinic object
            if (!hasClinics) {
              allClinics.add(ClinicModel.fromJson(item));
            }
          }
        }
        return allClinics;
      }

      // If it's 302, it means the server is redirecting to login.
      if (response.statusCode == 302) {
        throw 'Unauthorized: The server redirected to login. Please login again or check if you have Admin permissions.';
      }

      throw 'Failed to get doctors: Server returned ${response.statusCode}';
    } catch (e) {
      print('Failed to get patient clinics: $e');
      throw e.toString();
    }
  }

  /// جلب مواعيد الباشنت (upcoming + past)
  Future<List<dynamic>> getPatientAppointments() async {
    try {
      final endpoints = [
        'Patient/BookingApi/GetMyBookings',
        'Patient/AppointmentApi/GetMyAppointments',
        'Patient/ScheduleApi/GetPatientBookings',
        'Doctor/ScheduleApi/GetPatientBookings',
      ];

      for (final endpoint in endpoints) {
        try {
          final response = await _dio.get(
            endpoint,
            options: Options(validateStatus: (status) => true),
          );

          print('===== Patient Appointments [$endpoint] =====');
          print('Status: ${response.statusCode}');
          print('Data: ${response.data}');

          if (response.statusCode != 200 && response.statusCode != 201)
            continue;

          if (response.data is List) return response.data as List;

          if (response.data is Map<String, dynamic>) {
            final map = response.data as Map<String, dynamic>;
            for (final key in [
              'bookings',
              'appointments',
              'data',
              'items',
              'result',
            ]) {
              if (map[key] is List) return map[key] as List;
            }
          }
        } catch (e) {
          print('Endpoint $endpoint failed: $e');
          continue;
        }
      }
      return [];
    } catch (e) {
      print('Failed to get patient appointments: $e');
      return [];
    }
  }

  /// حجز موعد للباشنت
  Future<bool> createPatientBooking({
    required int clinicId,
    required String date,
    required String timeSlot,
  }) async {
    try {
      final body = {
        'ClinicId': clinicId,
        'BookingDate': date,
        'TimeSlot': timeSlot,
      };

      print('Creating booking: $body');

      final endpoints = [
        'Patient/BookingApi/CreateBooking',
        'Patient/AppointmentApi/CreateAppointment',
        'Doctor/ScheduleApi/CreateBooking',
      ];

      for (final endpoint in endpoints) {
        try {
          final response = await _dio.post(
            endpoint,
            data: body,
            options: Options(validateStatus: (status) => true),
          );

          print(
            'CreateBooking [$endpoint]: ${response.statusCode} - ${response.data}',
          );

          if (response.statusCode == 200 || response.statusCode == 201)
            return true;
        } catch (e) {
          print('Endpoint $endpoint failed: $e');
          continue;
        }
      }
      return false;
    } catch (e) {
      print('Failed to create booking: $e');
      return false;
    }
  }

  /// تعديل الملف الشخصي للباشنت
  Future<bool> editPatientProfile({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? address,
    String? gender,
    String? dateOfBirth,
    String? imagePath,
  }) async {
    try {
      final mapData = <String, dynamic>{};
      if (fullName != null && fullName.isNotEmpty)
        mapData['FullName'] = fullName;
      if (email != null && email.isNotEmpty) mapData['Email'] = email;
      if (phoneNumber != null && phoneNumber.isNotEmpty)
        mapData['PhoneNumber'] = phoneNumber;
      if (address != null && address.isNotEmpty) mapData['Address'] = address;
      if (gender != null && gender.isNotEmpty) mapData['Gender'] = gender;
      if (dateOfBirth != null && dateOfBirth.isNotEmpty)
        mapData['DateOfBirth'] = dateOfBirth;

      final formData = FormData.fromMap(mapData);

      if (imagePath != null && imagePath.isNotEmpty) {
        formData.files.add(
          MapEntry('ImageFile', await MultipartFile.fromFile(imagePath)),
        );
      }

      print('Sending EditPatientProfile data: $mapData');

      final response = await _dio.put(
        'Patient/ProfileApi/EditProfile',
        data: formData,
        options: Options(validateStatus: (status) => true),
      );

      print(
        'Edit Patient Profile Response: ${response.statusCode} - ${response.data}',
      );

      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 201) {
        return true;
      } else {
        String errorMessage = 'Failed to edit profile';
        if (response.data is Map<String, dynamic>) {
          if (response.data.containsKey('message')) {
            errorMessage = response.data['message'];
          } else if (response.data.containsKey('errors')) {
            errorMessage = response.data['errors'].toString();
          } else {
            errorMessage = response.data.toString();
          }
        } else if (response.data != null &&
            response.data.toString().isNotEmpty) {
          errorMessage = response.data.toString();
        }
        throw errorMessage;
      }
    } catch (e) {
      print('Failed to edit patient profile: $e');
      throw e.toString();
    }
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
    try {
      final mapData = <String, dynamic>{
        'FullName': fullName ?? '',
        'PhoneNumber': phoneNumber ?? '',
        'Address': address ?? '',
        'Gender': gender ?? '',
        'DepartmentId': departmentId ?? 1,
      };
      if (dateOfBirth != null && dateOfBirth.trim().isNotEmpty) {
        mapData['DateOfBirth'] = dateOfBirth;
      }
      if (aboutMe != null && aboutMe.trim().isNotEmpty) {
        mapData['AboutMe'] = aboutMe;
      }

      print(
        '=== EditDoctorProfile sending fields: $mapData hasImage: ${imagePath != null && imagePath.isNotEmpty} ===',
      );

      // Always use FormData — server uses [FromForm]
      final formData = FormData.fromMap(mapData);

      if (imagePath != null && imagePath.isNotEmpty) {
        formData.files.add(
          MapEntry('ImageFile', await MultipartFile.fromFile(imagePath)),
        );
      }

      final response = await _dio.put(
        'Doctor/ProfileApi/EditProfile',
        data: formData,
        options: Options(
          validateStatus: (s) => true,
          sendTimeout: const Duration(minutes: 3),
        ),
      );

      print(
        'Edit Doctor Profile Response: ${response.statusCode} - ${response.data}',
      );

      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 201) {
        return true;
      } else {
        String errorMessage = 'Failed to edit profile (${response.statusCode})';
        if (response.data is Map<String, dynamic>) {
          final errors = response.data['errors'];
          if (errors != null) {
            errorMessage = errors.toString();
          } else {
            errorMessage =
                response.data['message']?.toString() ??
                response.data.toString();
          }
        } else if (response.data != null &&
            response.data.toString().trim().isNotEmpty) {
          errorMessage = response.data.toString();
        }
        throw errorMessage;
      }
    } catch (e) {
      print('Failed to edit doctor profile: $e');
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>?> getDoctorProfile() async {
    try {
      final response = await _dio.get(
        'Doctor/ProfileApi/GetProfile',
        options: Options(validateStatus: (status) => true),
      );
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else if (response.statusCode == 200 &&
          response.data is List &&
          response.data.isNotEmpty) {
        return response.data[0] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Failed to get doctor profile: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getPatientProfile() async {
    try {
      final response = await _dio.get(
        'Patient/ProfileApi/GetProfile',
        options: Options(validateStatus: (status) => true),
      );
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else if (response.statusCode == 200 &&
          response.data is List &&
          response.data.isNotEmpty) {
        return response.data[0] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Failed to get patient profile: $e');
      return null;
    }
  }

  // ============================================================
  // Delete Profile/Image APIs
  // ============================================================

  Future<bool> deletePatientImage() async {
    return _deleteRequest('Patient/ProfileApi/DeleteImage');
  }

  Future<bool> deletePatientAccount() async {
    return _deleteRequest('Patient/ProfileApi/DeleteAccount');
  }

  Future<bool> deleteDoctorImage() async {
    return _deleteRequest('Doctor/ProfileApi/DeleteImage');
  }

  Future<bool> deleteDoctorAccount() async {
    return _deleteRequest('Doctor/ProfileApi/DeleteAccount');
  }

  Future<bool> _deleteRequest(String endpoint) async {
    try {
      final response = await _dio.delete(
        endpoint,
        options: Options(validateStatus: (status) => true),
      );
      print(
        'Delete [$endpoint] Response: ${response.statusCode} - ${response.data}',
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        String errorMessage = 'Failed to delete';
        if (response.data is Map<String, dynamic> &&
            response.data.containsKey('message')) {
          errorMessage = response.data['message'];
        } else if (response.data is String) {
          errorMessage = response.data;
        }
        throw errorMessage;
      }
    } catch (e) {
      print('Failed to call $endpoint: $e');
      throw e.toString();
    }
  }

  // ============================================================
  // Admin APIs
  // ============================================================

  Future<List<dynamic>> adminGetAllDoctors() async {
    try {
      final response = await _dio.get(
        'Admin/DoctorApi/GetAllDoctors',
        queryParameters: {'currentPage': 1},
        options: Options(validateStatus: (status) => true),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is List) return response.data as List;
        if (response.data is Map<String, dynamic>) {
          final map = response.data as Map<String, dynamic>;
          for (final key in ['doctors', 'data', 'items', 'result']) {
            if (map[key] is List) return map[key] as List;
          }
        }
      }
      return [];
    } catch (e) {
      print('Admin GetAllDoctors error: $e');
      return [];
    }
  }

  Future<bool> adminDeleteDoctor(int id) async {
    return _deleteRequest('Admin/DoctorApi/DeleteDoctor/$id');
  }

  Future<List<dynamic>> adminGetAllPatients() async {
    try {
      final response = await _dio.get(
        'Admin/PatientApi/GetAllPatients',
        queryParameters: {'currentPage': 1},
        options: Options(validateStatus: (status) => true),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is List) return response.data as List;
        if (response.data is Map<String, dynamic>) {
          final map = response.data as Map<String, dynamic>;
          for (final key in ['patients', 'data', 'items', 'result']) {
            if (map[key] is List) return map[key] as List;
          }
        }
      }
      return [];
    } catch (e) {
      print('Admin GetAllPatients error: $e');
      return [];
    }
  }

  Future<bool> adminDeletePatient(int id) async {
    return _deleteRequest('Admin/PatientApi/DeletePatient/$id');
  }
}

