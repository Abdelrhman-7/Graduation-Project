// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
// IO-only imports — guarded at runtime via kIsWeb
// ignore: uri_does_not_exist
import 'api_manager_io.dart'
    if (dart.library.html) 'api_manager_web.dart'
    as platform_helper;
import 'package:graduationproject/data/models/schudule/cliniceSchedual.dart';
import 'package:graduationproject/data/models/schudule/creatSchudel.dart';
import 'package:graduationproject/data/models/schudule/doctorModel.dart';
import '../models/Auth/login_model.dart';
import '../models/Auth/register_model.dart';
import '../models/Auth/logout_model.dart';
import '../models/booking/booking_model.dart';
import '../repository/shared_pref_controller.dart';

class ApiManager {
  final Dio _dio;

  // On Web we use an in-memory CookieJar; on IO we use PersistCookieJar.
  // Both implement the CookieJar interface.
  final CookieJar _cookieJar;

  static const String _baseUrl = 'http://clinicbook.runasp.net/api/';

  ApiManager._internal(this._dio, this._cookieJar);

  /// إنشاء وإعداد مكتبة Dio لإجراء الاتصالات مع تهيئة الكوكيز والـ Interceptors
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

    // Setup SSL fix and cookie jar — IO-only features skipped on Web
    final cookieJar = await platform_helper.createCookieJar(dio);

    // ① إزالة Secure flag من الـ Set-Cookie عشان تتحفظ وتتبعت صح على HTTP
    //مسئوله عن نعجيل ال cookes من Https الي Http عشان تعرف تتعامل ب ال Http
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

    // ② CookieManager بيتضاف بعد interceptor إزالة secure عشان يحفظ الـ cookies صح
    dio.interceptors.add(CookieManager(cookieJar));

    // معترض إعادة المحاولة: يعيد محاولة إرسال الطلب تلقائياً مرة واحدة عند حدوث انقطاع في الشبكة
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
                //Query Parameters هي البيانات اللي بتتبعت في آخر الـ URL بعد علامة
                queryParameters: opts.queryParameters,
                options: Options(
                  method: opts.method,
                  headers: opts.headers,
                  extra: opts.extra,
                ),
              );
              //رجع الكلب تاني بعد ما الخطاء يروح
              handler.resolve(response);
              return;
            } catch (retryError) {
              if (retryError is DioException) {
                handler.next(retryError);
              } else {
                handler.next(error);
              }
              //علشان يخرج من الدالة ومينفذش أي كود بعده.
              return;
            }
          }
          handler.next(error);
        },
      ),
    );

    // معترض السجلات: لطباعة تفاصيل الطلبات والردود في الكونسول لتسهيل عملية التصحيح (Debugging)
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        requestHeader: true,
      ),
    );

    // معترض المصادقة: لجلب توكن الـ JWT المخزن محلياً وإضافته تلقائياً في هيدر الطلب
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = SharedPrefController();
          final token = await prefs.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            // إضافة التوكن في الهيدر بصيغة Bearer
            // Authorization: Bearer abc123xyz
          }
          return handler.next(options);
        },
      ),
    );

    return ApiManager._internal(dio, cookieJar);
  }

  //مساول عن حفظ ال cookes (جلسه)
  CookieJar get cookieJar => _cookieJar;

  // دالة مساعدة لاستخراج القوائم من استجابة السيرفر بغض النظر عن مسمى الحقل القادم بتقبل اي شكل للداتا
  List<dynamic> _extractListFromResponse(dynamic data, {List<String>? keys}) {
    if (data is List) return data;
    if (data is Map) {
      // عشان نقدر نتعامل معاه بسهولة و اكثر امان
      final map = Map<String, dynamic>.from(data);
      final searchKeys =
          keys ??
          //ابحث عن المفاتيح دي
          [
            'items',
            'data',
            'result',
            'doctors',
            'Doctors',
            'clinics',
            'Clinics',
            'schedules',
            'Schedules',
            'bookings',
            'Bookings',
            'appointments',
            'Appointments',
            r'$values',
          ];
      for (final key in searchKeys) {
        if (map[key] is List) return map[key] as List;
      }
      for (final value in map.values) {
        if (value is List) return value;
      }
    }
    // يرجع List فاضي بدل ما التطبيق ي crash
    return [];
  }

  // دالة مساعدة لاستخراج رسالة الخطأ من استجابة السيرفر
  String? _extractErrorMessage(dynamic data) {
    if (data is String && data.trim().isNotEmpty) return data.trim();
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      for (final key in ['message', 'Message', 'title', 'Title', 'error']) {
        final value = map[key];
        if (value is String && value.trim().isNotEmpty) return value.trim();
      }
    }
    return null;
  }

  // دالة لتحليل وتفصيل أخطاء الـ API وعرضها بشكل نصي واضح
  String _parseApiError(Response response, String defaultMsg) {
    final data = response.data;
    if (data == null) return defaultMsg;
    if (data is Map) {
      final errors = data['errors'];
      if (errors != null) {
        if (errors is Map) {
          final list = [];
          // "لف على كل الأخطاء، وخد القيمة بتاعتها (v) عشان تعرضها للمستخدم"
          errors.forEach((key, value) {
            if (value is List) {
              list.add(value.join(', '));
            } else {
              list.add(value.toString());
            }
          });
          if (list.isNotEmpty) return list.join('\n');
        }
        return errors.toString();
      }
      final msg =
          data['message'] ?? data['Message'] ?? data['title'] ?? data['Title'];
      if (msg != null && msg.toString().trim().isNotEmpty) {
        return msg.toString().trim();
      }
      return data.toString();
    }
    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }
    return defaultMsg;
  }

  // دالة لتحويل البيانات القادمة إلى قائمة من كائنات عيادات (ClinicModel)
  //في حاله بو كان عنصر واحد هيرجع Map
  // لو اكتر من عنصر هيرجه List
  //في النهايه كله هيبقا List
  List<ClinicModel> _parseClinicList(dynamic data) {
    if (data is Map &&
        (data.containsKey('clinicId') ||
            data.containsKey('ClinicId') ||
            data.containsKey('id') ||
            data.containsKey('Id')) &&
        (data.containsKey('name') ||
            data.containsKey('Name') ||
            data.containsKey('address') ||
            data.containsKey('Address'))) {
      return [ClinicModel.fromJson(Map<String, dynamic>.from(data))];
    }

    final clinics = <ClinicModel>[];
    for (final item in _extractListFromResponse(data)) {
      if (item is Map) {
        try {
          clinics.add(ClinicModel.fromJson(Map<String, dynamic>.from(item)));
        } catch (e) {
          print('Skipping invalid clinic item: $e');
        }
      }
    }
    return clinics;
  }

  // دالة لتحويل البيانات القادمة إلى قائمة من كائنات حجوزات (BookingModel)
  List<BookingModel> _parseBookingList(dynamic data) {
    return _extractListFromResponse(data)
        .whereType<Map<String, dynamic>>()
        .map(BookingModel.fromJson)
        .where((b) => b.id > 0)
        .toList();
    //بنحول من json الي لBookModel
  }

  // تحويل أخطاء الاتصال الفنية لرسائل مفهومة وودية للمستخدم
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

  // دالة لتحليل وتحويل البيانات القادمة إلى كائن طبيب (DoctorModel)
  DoctorModel? _parseDoctorResponse(dynamic data) {
    if (data == null) return null;
    if (data is! Map) return null;

    final map = Map<String, dynamic>.from(data);
    //لف على كل الأسماء الممكنة اللي السيرفر ممكن يحط فيها الدكتو
    for (final key in [
      'doctor',
      'Doctor',
      'data',
      'Data',
      'result',
      'Result',
    ]) {
      final nested = map[key];
      if (nested is Map) {
        return DoctorModel.fromJson(Map<String, dynamic>.from(nested));
      }
    }
    //لو مفتاح من دول موجود بيبقا دكتور

    if (map.containsKey('id') ||
        map.containsKey('Id') ||
        map.containsKey('doctorId') ||
        map.containsKey('DoctorId') ||
        map.containsKey('fullName') ||
        map.containsKey('FullName') ||
        map.containsKey('name') ||
        map.containsKey('Name')) {
      return DoctorModel.fromJson(map);
    }

    return null;
  }

  // دالة مساعدة لإرسال طلب حذف (DELETE) للسيرفر مع معالجة النتيجة
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

  // ==========================================
  // AccountApi
  // ==========================================

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

              // السيرفر في login API مش بيرجع البيانات دي
              // فهي مش متاحة وقت تسجيل الدخول
              // وبتتجاب يعدين أو من endpoint تاني
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        return RegisterResponse(
          status: true,
          message: response.data is Map<String, dynamic>
              ? (response.data['message']?.toString() ?? 'Registration successful')
              : response.data.toString(),
        );
      }

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
      await _cookieJar.deleteAll();
      if (response.statusCode == 200) {
        return LogoutResponse(status: true, message: 'Logout Successful');
      }
      return LogoutResponse(status: false, message: 'Logout failed');
    } catch (e) {
      await _cookieJar.deleteAll();
      return LogoutResponse(status: true, message: 'Logout Successful');
    }
  }

  Future<bool> chooseRole(String role) async {
    try {
      final response = await _dio.get(
        'Identity/AccountApi/ChooseRole',
        queryParameters: {'role': role},
        options: Options(validateStatus: (status) => true),
      );
      print('ChooseRole [$role]: ${response.statusCode} - ${response.data}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('ChooseRole error: $e');
      return false;
    }
  }
  // ==========================================
  // ClinicApi
  // ==========================================

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

  Future<ClinicModel?> getClinic(int id) async {
    try {
      final response = await _dio.get(
        'Doctor/ClinicApi/GetClinic/$id',
        options: Options(validateStatus: (status) => true),
      );
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data is Map) {
        return ClinicModel.fromJson(Map<String, dynamic>.from(response.data));
      }
      return null;
    } catch (e) {
      print('getClinic error: $e');
      return null;
    }
  }

  // جلب كل العيادات الخاصة بالطبيب
  Future<List<ClinicModel>> getDoctorClinics() async {
    try {
      final response = await _dio.get(
        'Doctor/ClinicApi/GetAllClinics',
        queryParameters: {'currentPage': 1},
        options: Options(validateStatus: (status) => true),
      );

      print('===== GetAllClinics RAW RESPONSE =====');
      print('Status: ${response.statusCode}');
      print('Data Type: ${response.data.runtimeType}');
      print('Data: ${response.data}');
      print('======================================');

      if (response.statusCode == 302 || response.statusCode == 401) {
        throw 'Session expired. Please login again.';
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw _extractErrorMessage(response.data) ??
            'Server returned ${response.statusCode}';
      }

      final data = response.data;
      if (data == null) return [];
      if (data is String) {
        if (data.trim().isEmpty) return [];
        throw data.trim();
      }

      return _parseClinicList(data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 302 || status == 401) {
        throw 'Session expired. Please login again.';
      }
      final message = _extractErrorMessage(e.response?.data);
      throw message ?? e.message ?? 'Network error while loading clinics';
    } catch (e) {
      print('Failed to get clinics: $e');
      final msg = e.toString().replaceFirst('Exception: ', '').trim();
      if (msg.isEmpty) {
        throw 'Failed to load clinics. Please try again.';
      }
      if (msg.startsWith('Failed to load clinics')) {
        throw msg;
      }
      throw 'Failed to load clinics: $msg';
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

  // ==========================================
  // ScheduleApi
  // ==========================================

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

  Future<Map<String, dynamic>?> getSchedule(int id) async {
    try {
      final response = await _dio.get(
        'Doctor/ScheduleApi/GetSchedule/$id',
        options: Options(validateStatus: (status) => true),
      );
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data is Map) {
        return Map<String, dynamic>.from(response.data);
      }
      return null;
    } catch (e) {
      print('getSchedule error: $e');
      return null;
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

  // ==========================================
  // BookingApi
  // ==========================================

  Future<List<dynamic>> getClinicBookings(int clinicId) async {
    final endpoints = [
      'Doctor/BookingApi/GetClinicBookings/$clinicId',
      'Doctor/BookingApi/GetBookings/$clinicId',
      'Doctor/ScheduleApi/GetClinicBookings',
    ];

    for (final endpoint in endpoints) {
      try {
        final response = await _dio.get(
          endpoint,
          queryParameters: endpoint.contains('GetClinicBookings')
              ? {'clinicId': clinicId, 'currentPage': 1}
              : {'currentPage': 1},
          options: Options(validateStatus: (status) => true),
        );

        print('GetClinicBookings [$endpoint]: ${response.statusCode}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          final items = _extractListFromResponse(response.data);
          if (items.isNotEmpty) return items;
        }
      } catch (e) {
        print('GetClinicBookings endpoint $endpoint failed: $e');
      }
    }
    return [];
  }

  /// إلغاء حجز للباشنت
  Future<bool> cancelPatientBooking(int bookingId) async {
    await chooseRole('Patient');
    try {
      final response = await _dio.post(
        'Patient/AppointmentApi/CancelAppointment/$bookingId',
        options: Options(validateStatus: (status) => true),
      );
      print('CancelPatientAppointment: ${response.statusCode}');
      return response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
    } catch (e) {
      print('CancelPatientAppointment failed: $e');
      return false;
    }
  }

  /// إلغاء حجز من الدكتور
  Future<bool> cancelDoctorAppointment(int bookingId) async {
    await chooseRole('Doctor');
    try {
      final response = await _dio.post(
        'Doctor/AppointmentApi/CancelAppointment/$bookingId',
        options: Options(validateStatus: (status) => true),
      );
      print('CancelDoctorAppointment: ${response.statusCode}');
      return response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
    } catch (e) {
      print('CancelDoctorAppointment failed: $e');
      return false;
    }
  }

  /// يدفع المريض قيمة الحجز بالبطاقة الائتمانية
  Future<Map<String, dynamic>> payAppointmentByCard({
    required int appointmentId,
    required String cardHolderName,
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
  }) async {
    await chooseRole('Patient');
    try {
      // 1. Generate Stripe Token by calling Stripe API
      final stripeDio = Dio();
      final stripeBody = {
        'card[number]': cardNumber.replaceAll(' ', ''),
        'card[exp_month]': int.tryParse(expiryMonth) ?? 1,
        'card[exp_year]': int.tryParse(expiryYear) ?? DateTime.now().year,
        'card[cvc]': cvv,
      };

      print(
        'Requesting Stripe Token for card expiration $expiryMonth/$expiryYear...',
      );
      final stripeRes = await stripeDio.post(
        'https://api.stripe.com/v1/tokens',
        data: stripeBody,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {'Authorization': 'Bearer pk_test_TYooMQauvdEDq54NiTphI7jx'},
          validateStatus: (status) => true,
        ),
      );

      print('Stripe token response code: ${stripeRes.statusCode}');
      print('Stripe token response data: ${stripeRes.data}');
      if (stripeRes.statusCode != 200) {
        String errorMsg =
            'Payment processing failed. Please check your card details and try again.';
        if (stripeRes.data is Map && stripeRes.data['error'] != null) {
          final stripeError = stripeRes.data['error'];
          final stripeMsg = stripeError['message']?.toString() ?? '';
          final stripeCode = stripeError['code']?.toString() ?? '';
          if (stripeCode == 'card_declined') {
            errorMsg = 'Your card was declined. Please use a different card.';
          } else if (stripeCode == 'invalid_expiry_year' ||
              stripeCode == 'invalid_expiry_month') {
            errorMsg = 'Invalid card expiry date. Please check and try again.';
          } else if (stripeCode == 'incorrect_cvc') {
            errorMsg = 'Incorrect CVV. Please check your card and try again.';
          } else if (stripeCode == 'invalid_number') {
            errorMsg = 'Invalid card number. Please check and try again.';
          } else if (stripeMsg.isNotEmpty) {
            errorMsg = stripeMsg;
          }
        }
        return {'success': false, 'message': errorMsg};
      }
      // أنت هنا بتاخد Token اللي رجع من Stripe response
      final stripeToken = stripeRes.data['id'] as String?;
      if (stripeToken == null || stripeToken.isEmpty) {
        return {
          'success': false,
          'message': 'Failed to generate payment token',
        };
      }

      print('Generated Stripe Token: $stripeToken. Sending to backend...');
      // 2. Send token to backend
      final cleanCardNumber = cardNumber.replaceAll(' ', '');
      final cleanCvv = cvv.trim();
      final expMonth = int.tryParse(expiryMonth.trim()) ?? 1;
      final expYear = int.tryParse(expiryYear.trim()) ?? DateTime.now().year;
      final holderName = cardHolderName.trim().isNotEmpty ? cardHolderName.trim() : 'Card Holder';

      // Debug: print actual values before sending
      print('=== PAYMENT DEBUG ===');
      print('CardNumber: "$cleanCardNumber" (len=${cleanCardNumber.length})');
      print('CVV: "$cleanCvv" (len=${cleanCvv.length})');
      print('ExpiryMonth: $expMonth, ExpiryYear: $expYear');
      print('CardHolderName: "$holderName"');
      print('StripeToken: "$stripeToken"');
      print('===================');

      final formData = FormData.fromMap({
        'StripeToken': stripeToken,
        'CardNumber': cleanCardNumber,
        'CVV': cleanCvv,
        'ExpiryMonth': expMonth,
        'ExpiryYear': expYear,
        'CardHolderName': holderName,
      });

      final response = await _dio.post(
        'Patient/AppointmentApi/PayAppointmentByCard/$appointmentId',
        data: formData,
        options: Options(
          validateStatus: (status) => true,
          sendTimeout: const Duration(seconds: 45),
          receiveTimeout: const Duration(seconds: 45),
        ),
      );

      print(response.statusCode);
      print(response.headers);
      print(response.data);

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return {'success': true, 'message': 'Payment completed successfully'};
      } else {
        final errorMsg = _parseApiError(response, 'Payment failed');
        return {'success': false, 'message': errorMsg};
      }
    } on DioException catch (e) {
      print('PayAppointmentByCard DioException: ${e.type} - ${e.message}');
      final msg = _extractErrorMessage(e.response?.data) ?? _friendlyError(e);
      return {'success': false, 'message': msg};
    } catch (e) {
      print('PayAppointmentByCard error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /////////////
  ///ِAppointments///
  /////////////////
  Future<List<dynamic>> getPatientAllAppointments({int currentPage = 1}) async {
    try {
      final response = await _dio.get(
        'Patient/AppointmentApi/GetAllAppointments',
        queryParameters: {'currentPage': currentPage},
        options: Options(validateStatus: (status) => true),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return _extractListFromResponse(response.data);
      }
      return [];
    } catch (e) {
      print('getPatientAllAppointments error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getPatientAppointment(int id) async {
    try {
      final response = await _dio.get(
        'Patient/AppointmentApi/GetAppointment/$id',
        options: Options(validateStatus: (status) => true),
      );
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data is Map) {
        return Map<String, dynamic>.from(response.data);
      }
      return {'error': 'API Error ${response.statusCode}: ${response.data}'};
    } catch (e) {
      print('getPatientAppointment error: $e');
      return {'error': 'Exception: $e'};
    }
  }

  Future<List<dynamic>> getDoctorAllReviews() async {
    await chooseRole('Doctor');
    try {
      final response = await _dio.get(
        'Doctor/ReviewApi/GetAllReviews',
        options: Options(validateStatus: (status) => true),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return _extractListFromResponse(response.data);
      }
      return [];
    } catch (e) {
      print('getDoctorAllReviews error: $e');
      return [];
    }
  }

  Future<String?> addDoctorReview({
    required int doctorId,
    required int rating,
    required String comment,
  }) async {
    await chooseRole('Patient');
    try {
      final response = await _dio.post(
        'Patient/BookingApi/CreateDoctorReview/$doctorId',
        data: {'rating': rating, 'comment': comment},
        options: Options(validateStatus: (status) => true),
      );
      print('AddReview response: ${response.statusCode} - ${response.data}');
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return null; // success مفيش حاجه لازم ترجع
      }
      return 'Error ${response.statusCode}: ${response.data?.toString()}';
    } catch (e) {
      print('addDoctorReview failed: $e');
      return 'Exception: $e';
    }
  }

  Future<String?> editDoctorReview({
    required int reviewId,
    required int rating,
    required String comment,
  }) async {
    await chooseRole('Patient');
    try {
      final response = await _dio.put(
        'Patient/BookingApi/EditDoctorReview/$reviewId',
        data: {'rating': rating, 'comment': comment},
        options: Options(validateStatus: (status) => true),
      );
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return null; // success
      }
      return 'Error ${response.statusCode}: ${response.data?.toString()}';
    } catch (e) {
      print('editDoctorReview failed: $e');
      return 'Exception: $e';
    }
  }

  Future<String?> deleteDoctorReview(int reviewId) async {
    await chooseRole('Patient');
    try {
      final response = await _dio.delete(
        'Patient/BookingApi/DeleteDoctorReview/$reviewId',
        options: Options(validateStatus: (status) => true),
      );
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return null; // success
      }
      return 'Error ${response.statusCode}: ${response.data?.toString()}';
    } catch (e) {
      print('deleteDoctorReview failed: $e');
      return 'Exception: $e';
    }
  }

  Future<List<dynamic>> getPatientDoctorReviews(int doctorId) async {
    await chooseRole('Patient');
    try {
      final response = await _dio.get(
        'Patient/BookingApi/GetDoctorReviews/$doctorId',
        options: Options(validateStatus: (status) => true),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return _extractListFromResponse(response.data);
      }
      return [];
    } catch (e) {
      print('getPatientDoctorReviews error: $e');
      return [];
    }
  }

  Future<bool> editPatientAppointment(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        'Patient/AppointmentApi/EditAppointment/$id',
        data: data,
        options: Options(validateStatus: (status) => true),
      );
      return response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
    } catch (e) {
      print('editPatientAppointment error: $e');
      return false;
    }
  }

  Future<bool> deleteAppointmentPatientImage(int id) async {
    return _deleteRequest('Patient/AppointmentApi/DeletePatientImage/$id');
  }

  Future<List<dynamic>> getDoctorAllAppointments({int currentPage = 1}) async {
    try {
      final response = await _dio.get(
        'Doctor/AppointmentApi/GetAllAppointments',
        queryParameters: {'currentPage': currentPage},
        options: Options(validateStatus: (status) => true),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return _extractListFromResponse(response.data);
      }
      return [];
    } catch (e) {
      print('getDoctorAllAppointments error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getDoctorAppointment(int id) async {
    try {
      final response = await _dio.get(
        'Doctor/AppointmentApi/GetAppointment/$id',
        options: Options(validateStatus: (status) => true),
      );
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data is Map) {
        return Map<String, dynamic>.from(response.data);
      }
      return null;
    } catch (e) {
      print('getDoctorAppointment error: $e');
      return null;
    }
  }

  Future<bool> confirmDoctorAppointment(int id) async {
    try {
      final response = await _dio.post(
        'Doctor/AppointmentApi/ConfirmAppointment/$id',
        options: Options(validateStatus: (status) => true),
      );
      return response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
    } catch (e) {
      print('confirmDoctorAppointment error: $e');
      return false;
    }
  }

  Future<bool> completeDoctorAppointment(int id) async {
    try {
      final response = await _dio.post(
        'Doctor/AppointmentApi/CompleteAppointment/$id',
        options: Options(validateStatus: (status) => true),
      );
      return response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
    } catch (e) {
      print('completeDoctorAppointment error: $e');
      return false;
    }
  }

  /// جلب طلبات الحجز المعلقة للطبيب
  Future<List<BookingModel>> getDoctorPendingBookings({
    int currentPage = 1,
  }) async {
    final endpoints = [
      'Doctor/BookingApi/GetPendingBookings',
      'Doctor/BookingApi/GetAllBookings',
    ];

    for (final endpoint in endpoints) {
      try {
        final response = await _dio.get(
          endpoint,
          queryParameters: {'currentPage': currentPage},
          options: Options(validateStatus: (status) => true),
        );

        print('DoctorPendingBookings [$endpoint]: ${response.statusCode}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          final bookings = _parseBookingList(response.data);
          if (bookings.isNotEmpty) {
            return bookings.where((b) => b.isPending).toList();
          }
          return bookings;
        }
      } catch (e) {
        print('DoctorPendingBookings endpoint $endpoint failed: $e');
      }
    }
    return [];
  }

  /// قبول حجز
  Future<bool> acceptDoctorBooking(int bookingId) async {
    final endpoints = [
      'Doctor/BookingApi/AcceptBooking/$bookingId',
      'Doctor/BookingApi/ApproveBooking/$bookingId',
    ];

    for (final endpoint in endpoints) {
      try {
        final response = await _dio.post(
          endpoint,
          options: Options(validateStatus: (status) => true),
        );

        print('AcceptBooking [$endpoint]: ${response.statusCode}');

        if (response.statusCode == 200 ||
            response.statusCode == 201 ||
            response.statusCode == 204) {
          return true;
        }
      } catch (e) {
        print('AcceptBooking endpoint $endpoint failed: $e');
      }
    }
    return false;
  }

  /// رفض حجز
  Future<bool> rejectDoctorBooking(int bookingId) async {
    final endpoints = [
      'Doctor/BookingApi/RejectBooking/$bookingId',
      'Doctor/BookingApi/DenyBooking/$bookingId',
    ];

    for (final endpoint in endpoints) {
      try {
        final response = await _dio.post(
          endpoint,
          options: Options(validateStatus: (status) => true),
        );

        print('RejectBooking [$endpoint]: ${response.statusCode}');

        if (response.statusCode == 200 ||
            response.statusCode == 201 ||
            response.statusCode == 204) {
          return true;
        }
      } catch (e) {
        print('RejectBooking endpoint $endpoint failed: $e');
      }
    }
    return false;
  }

  /// جلب مواعيد عيادة معينة باستخدام Patient BookingApi
  Future<List<dynamic>> getPatientClinicSchedules({
    required int clinicId,
    int? doctorId,
    int currentPage = 1,
    String? dayOfWeek,
  }) async {
    try {
      final queryParams = <String, dynamic>{'currentPage': currentPage};
      if (dayOfWeek != null && dayOfWeek.isNotEmpty) {
        queryParams['dayOfWeek'] = dayOfWeek;
      }

      final response = await _dio.get(
        'Patient/BookingApi/GetClinicSchedules/$clinicId',
        queryParameters: queryParams,
        options: Options(validateStatus: (status) => true),
      );
      print(
        'GetClinicSchedules[clinic=$clinicId]: ${response.statusCode} - ${response.data}',
      );

      if (response.statusCode == 302 || response.statusCode == 401) {
        throw 'Session expired. Please login again.';
      }

      if (response.statusCode == 404) {
        throw 'Unable to load schedules. Please log in as a patient and try again.';
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw _extractErrorMessage(response.data) ??
            'Failed to load schedules (${response.statusCode})';
      }

      return _extractListFromResponse(
        response.data,
        keys: ['schedules', 'Schedules', 'items', 'data', 'result'],
      );
    } catch (e) {
      print('Failed to get clinic schedules: $e');
      rethrow;
    }
  }

  // ============================================================
  // Patient APIs
  // ============================================================

  /// جلب كل الأطباء للباشنت
  Future<List<DoctorModel>> getPatientDoctors({int currentPage = 1}) async {
    try {
      final response = await _dio.get(
        'Patient/BookingApi/GetAllDoctors',
        queryParameters: {'currentPage': currentPage},
        options: Options(validateStatus: (status) => true),
      );

      print('Patient BookingApi GetAllDoctors status: ${response.statusCode}');
      print('Patient BookingApi GetAllDoctors data: ${response.data}');

      if (response.statusCode == 302 || response.statusCode == 401) {
        throw 'Session expired. Please login again.';
      }

      if (response.statusCode == 404) {
        throw 'Unable to load doctors. Please log in as a patient and try again.';
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw _extractErrorMessage(response.data) ??
            'Failed to load doctors (${response.statusCode})';
      }

      final data = response.data;
      if (data == null) return [];
      if (data is String && data.trim().isEmpty) return [];

      final items = _extractListFromResponse(
        data,
        keys: ['doctors', 'Doctors', 'items', 'data', 'result'],
      );

      return items
          .whereType<Map>()
          .map((item) => DoctorModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 302 || status == 401) {
        throw 'Session expired. Please login again.';
      }
      if (status == 404) {
        throw 'Unable to load doctors. Please log in as a patient and try again.';
      }
      throw _extractErrorMessage(e.response?.data) ??
          e.message ??
          'Network error while loading doctors';
    } catch (e) {
      print('Failed to get patient doctors: $e');
      rethrow;
    }
  }

  /// جلب تفاصيل طبيب معين للباشنت
  Future<DoctorModel?> getPatientDoctorDetails(int doctorId) async {
    try {
      final response = await _dio.get(
        'Patient/BookingApi/GetDoctor/$doctorId',
        options: Options(validateStatus: (status) => true),
      );

      print('Patient BookingApi GetDoctor status: ${response.statusCode}');
      print('Patient BookingApi GetDoctor data: ${response.data}');

      if (response.statusCode == 302 || response.statusCode == 401) {
        throw 'Session expired. Please login again.';
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        return null;
      }

      return _parseDoctorResponse(response.data);
    } catch (e) {
      print('Failed to get patient doctor details: $e');
      rethrow;
    }
  }

  /// جلب عيادات طبيب معين للباشنت
  Future<List<ClinicModel>> getPatientDoctorClinics(
    int doctorId, {
    int currentPage = 1,
  }) async {
    try {
      final response = await _dio.get(
        'Patient/BookingApi/GetDoctorClinics/$doctorId',
        queryParameters: {'currentPage': currentPage},
        options: Options(validateStatus: (status) => true),
      );

      print(
        'Patient BookingApi GetDoctorClinics status: ${response.statusCode}',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final items = _extractListFromResponse(
          response.data,
          keys: ['clinics', 'Clinics', 'items', 'data', 'result'],
        );
        if (items.isEmpty && response.data is Map) {
          final map = Map<String, dynamic>.from(response.data as Map);
          if (map.containsKey('id') ||
              map.containsKey('clinicId') ||
              map.containsKey('name')) {
            return [ClinicModel.fromJson(map)];
          }
        }
        return items.whereType<Map>().map((item) {
          final map = Map<String, dynamic>.from(item);
          print('🏥 Clinic JSON keys: ${map.keys.toList()}');
          print('🏥 Clinic JSON data: $map');
          return ClinicModel.fromJson(map);
        }).toList();
      }
      return [];
    } catch (e) {
      print('Failed to get patient doctor clinics: $e');
      return [];
    }
  }

  /// ملخص الموعد قبل الحجز
  Future<Map<String, dynamic>?> getAppointmentSummary(int scheduleId) async {
    try {
      final response = await _dio.get(
        'Patient/BookingApi/AppointmentSummary/$scheduleId',
        options: Options(validateStatus: (status) => true),
      );

      print('AppointmentSummary status: ${response.statusCode}');
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Failed to get appointment summary: $e');
      return null;
    }
  }

  /// حجز موعد
  Future<dynamic> bookPatientAppointment({
    required int scheduleId,
    required String reasonForVisit,
    required String paymentMethod,
  }) async {
    try {
      final body = {
        'reasonForVisit': reasonForVisit,
        'paymentMethod': paymentMethod,
      };

      print(
        'Booking appointment: scheduleId=$scheduleId, reason=$reasonForVisit, payment=$paymentMethod',
      );

      final response = await _dio.post(
        'Patient/BookingApi/BookAppointment/$scheduleId',
        data: body,
        options: Options(
          contentType: 'application/json',
          validateStatus: (status) => true,
          sendTimeout: const Duration(seconds: 45),
          receiveTimeout: const Duration(seconds: 45),
        ),
      );

      print(
        'BookAppointment Response: ${response.statusCode} - ${response.data}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        String errorMessage = 'Failed to book appointment';
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          if (data.containsKey('message')) {
            errorMessage = data['message'];
          } else if (data.containsKey('errors')) {
            errorMessage = data['errors'].toString();
          } else if (data.containsKey('title')) {
            errorMessage = data['title'];
          } else {
            errorMessage = response.data.toString();
          }
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

  Future<dynamic> bookForOther(
    int scheduleId,
    Map<String, dynamic> data,
  ) async {
    await chooseRole('Patient');
    try {
      final response = await _dio.post(
        'Patient/BookingApi/BookForOther/$scheduleId',
        data: data,
        options: Options(
          contentType: 'application/json',
          validateStatus: (status) => true,
        ),
      );

      print('BookForOther Response: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        String errorMessage = 'Failed to book appointment for other';
        if (response.data is Map<String, dynamic> &&
            response.data.containsKey('message')) {
          errorMessage = response.data['message'];
        } else if (response.data is String) {
          errorMessage = response.data;
        }
        throw errorMessage;
      }
    } catch (e) {
      print('Failed to book appointment for other: $e');
      rethrow;
    }
  }

  /// جلب كل العيادات المتاحة للباشنت مع بيانات الطبيب
  Future<List<ClinicModel>> getPatientAllClinics() async {
    try {
      final response = await _dio.get(
        'Patient/BookingApi/GetAllDoctors',
        queryParameters: {'currentPage': 1},
        options: Options(validateStatus: (status) => true),
      );

      print(
        '===== Patient GetAllDoctors [Patient/BookingApi/GetAllDoctors] =====',
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
                        item['specialty'] ??
                        item['department'] ??
                        item['departmentName'];
                    c['doctorImageUrl'] =
                        item['imageUrl'] ??
                        item['profileImageUrl'] ??
                        item['displayImageUrl'];

                    // Fetch schedules if missing
                    if (c['clinicSchedules'] == null &&
                        c['schedules'] == null &&
                        c['id'] != null) {
                      try {
                        final schedRes = await _dio.get(
                          'Patient/BookingApi/GetClinicSchedules/${c['id']}',
                          queryParameters: {'currentPage': 1},
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
            final docId =
                item['id'] ??
                item['doctorId'] ??
                item['Id'] ??
                item['DoctorId'];
            if (!hasClinics &&
                !item.containsKey('consultationPrice') &&
                docId != null) {
              try {
                final clinicsRes = await _dio.get(
                  'Patient/BookingApi/GetDoctorClinics/$docId',
                  queryParameters: {'currentPage': 1},
                  options: Options(validateStatus: (s) => true),
                );
                if (clinicsRes.statusCode == 200) {
                  List<dynamic> docClinics = [];
                  if (clinicsRes.data is List) {
                    docClinics = clinicsRes.data;
                  } else if (clinicsRes.data is Map &&
                      clinicsRes.data['clinics'] is List)
                    // ignore: curly_braces_in_flow_control_structures
                    docClinics = clinicsRes.data['clinics'];

                  if (docClinics.isNotEmpty) {
                    hasClinics = true;
                    for (var c in docClinics) {
                      if (c is Map<String, dynamic>) {
                        c['doctorFullName'] = item['fullName'] ?? item['name'];
                        c['doctorSpecialty'] =
                            item['specialty'] ??
                            item['department'] ??
                            item['departmentName'];
                        c['doctorImageUrl'] =
                            item['imageUrl'] ??
                            item['profileImageUrl'] ??
                            item['displayImageUrl'];

                        // Fetch schedules if missing
                        if (c['clinicSchedules'] == null &&
                            c['schedules'] == null &&
                            c['id'] != null) {
                          try {
                            final schedRes = await _dio.get(
                              'Patient/BookingApi/GetClinicSchedules/${c['id']}',
                              queryParameters: {'currentPage': 1},
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
                print('Failed to get clinics for doctor $docId: $e');
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

          if (response.statusCode != 200 && response.statusCode != 201) {
            continue;
          }

          print('===== Patient Appointments [$endpoint] =====');
          print('Status: ${response.statusCode}');
          print('Data: ${response.data}');

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

          if (response.statusCode == 200 || response.statusCode == 201) {
            return true;
          }
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

  // ==========================================
  // DoctorApi
  // ==========================================

  // ============================================================
  // Admin APIs
  // ============================================================

  Future<bool> adminRegisterDoctor(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        'Admin/DoctorApi/RegisterDoctor',
        data: request.toMap(isDoctor: true),
        options: Options(validateStatus: (status) => true),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('adminRegisterDoctor error: $e');
      return false;
    }
  }

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
      String message = 'Failed to load doctors (${response.statusCode})';
      if (response.statusCode == 302) {
        message = 'Session expired or unauthorized. Please log in again.';
      } else if (response.data is Map && response.data['message'] != null) {
        message = response.data['message'].toString();
      }
      throw message;
    } catch (e) {
      print('Admin GetAllDoctors error: $e');
      rethrow;
    }
  }

  Future<bool> adminDeleteDoctor(int id) async {
    return _deleteRequest('Admin/DoctorApi/DeleteDoctor/$id');
  }

  Future<bool> adminToggleDoctorLock(int doctorId) async {
    try {
      final response = await _dio.post(
        'Admin/DoctorApi/ToggleDoctorLock/$doctorId',
        options: Options(validateStatus: (status) => true),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }
      throw response.data?.toString() ?? 'Failed to toggle lock';
    } catch (e) {
      print('Admin ToggleDoctorLock error: $e');
      throw e.toString();
    }
  }

  Future<bool> adminResetDoctorPassword(
    int doctorId,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      final response = await _dio.post(
        'Admin/DoctorApi/ResetDoctorPassword/$doctorId',
        data: {
          'NewPassword': newPassword,
          'ConfirmNewPassword': confirmPassword,
        },
        options: Options(validateStatus: (status) => true),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }
      throw response.data?.toString() ?? 'Failed to reset password';
    } catch (e) {
      print('Admin ResetDoctorPassword error: $e');
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>?> adminGetDoctor(int doctorId) async {
    try {
      final response = await _dio.get(
        'Admin/DoctorApi/GetDoctor/$doctorId',
        options: Options(validateStatus: (status) => true),
      );
      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return response.data as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      print('Admin GetDoctor error: $e');
      return null;
    }
  }

  Future<bool> adminEditDoctor(
    int doctorId,
    Map<String, dynamic> data,
    String? imagePath,
  ) async {
    try {
      final formData = FormData.fromMap(data);

      if (imagePath != null && imagePath.isNotEmpty) {
        formData.files.add(
          MapEntry('ImageFile', await MultipartFile.fromFile(imagePath)),
        );
      }

      final response = await _dio.put(
        'Admin/DoctorApi/EditDoctor/$doctorId',
        data: formData,
        options: Options(validateStatus: (status) => true),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }
      throw response.data?.toString() ?? 'Failed to edit doctor';
    } catch (e) {
      print('Admin EditDoctor error: $e');
      throw e.toString();
    }
  }

  Future<bool> adminDeleteDoctorImage(int doctorId) async {
    return _deleteRequest('Admin/DoctorApi/DeleteDoctorImage/$doctorId');
  }

  // ==========================================
  // HistoryApi
  // ==========================================

  /// جلب سجل مواعيد المريض بالكامل مع التصفح
  Future<List<dynamic>> getPatientHistoryAppointments({int page = 1}) async {
    try {
      final response = await _dio.get(
        'Patient/HistoryApi/GetAllAppointments',
        queryParameters: {'currentPage': page},
        options: Options(validateStatus: (status) => true),
      );
      print('PatientHistoryAppointments: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
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
      }
      return [];
    } catch (e) {
      print('Failed to get patient history appointments: $e');
      return [];
    }
  }

  /// جلب تفاصيل موعد محدد للمريض من السجل
  Future<Map<String, dynamic>?> getPatientHistoryAppointmentDetails(
    int appointmentId,
  ) async {
    try {
      final response = await _dio.get(
        'Patient/HistoryApi/GetAppointment/$appointmentId',
        options: Options(validateStatus: (status) => true),
      );
      print('PatientHistoryAppointmentDetails: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return response.data as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      print('Failed to get patient history appointment details: $e');
      return null;
    }
  }

  /// جلب سجل مواعيد الطبيب بالكامل مع التصفح
  Future<List<dynamic>> getDoctorHistoryAppointments({int page = 1}) async {
    try {
      final response = await _dio.get(
        'Doctor/HistoryApi/GetAllAppointments',
        queryParameters: {'currentPage': page},
        options: Options(validateStatus: (status) => true),
      );
      print('DoctorHistoryAppointments: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
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
      }
      return [];
    } catch (e) {
      print('Failed to get doctor history appointments: $e');
      return [];
    }
  }

  /// جلب تفاصيل موعد محدد للطبيب من السجل
  Future<Map<String, dynamic>?> getDoctorHistoryAppointmentDetails(
    int appointmentId,
  ) async {
    try {
      final response = await _dio.get(
        'Doctor/HistoryApi/GetAppointment/$appointmentId',
        options: Options(validateStatus: (status) => true),
      );
      print('DoctorHistoryAppointmentDetails: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return response.data as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      print('Failed to get doctor history appointment details: $e');
      return null;
    }
  }

  // ==========================================
  // NotificationApi
  // ==========================================

  Future<List<dynamic>> getPatientNotificationsFromApi({int page = 1}) async {
    try {
      await chooseRole('Patient');
      final response = await _dio.get(
        'Patient/NotificationApi/GetAllNotifications',
        queryParameters: {'currentPage': page},
        options: Options(validateStatus: (s) => true),
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is List) return data;
        // Some APIs wrap list in a key
        if (data is Map) {
          return data['data'] ?? data['items'] ?? data['notifications'] ?? [];
        }
      }
      return [];
    } catch (e) {
      print('getPatientNotificationsFromApi error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getPatientNotificationById(int id) async {
    try {
      await chooseRole('Patient');
      final response = await _dio.get(
        'Patient/NotificationApi/GetNotification/$id',
        options: Options(validateStatus: (s) => true),
      );
      if (response.statusCode == 200 && response.data is Map) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('getPatientNotificationById error: $e');
      return null;
    }
  }

  Future<bool> discardPatientNotification(int id) async {
    await chooseRole('Patient');
    return _deleteRequest('Patient/NotificationApi/DiscardNotification/$id');
  }

  // ==========================================
  // Doctor Notifications
  // ==========================================

  Future<List<dynamic>> getDoctorNotifications({int currentPage = 1}) async {
    await chooseRole('Doctor');
    try {
      final response = await _dio.get(
        'Doctor/NotificationApi/GetAllNotifications',
        queryParameters: {'currentPage': currentPage},
        options: Options(validateStatus: (status) => true),
      );

      print('GetAllNotifications: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final items = _extractListFromResponse(response.data);
        if (items.isNotEmpty) return items;
      }
    } catch (e) {
      print('getDoctorNotifications failed: $e');
    }
    return [];
  }

  Future<dynamic> getDoctorNotification(int id) async {
    try {
      final response = await _dio.get(
        'Doctor/NotificationApi/GetNotification/$id',
        options: Options(validateStatus: (status) => true),
      );

      print('GetNotification/$id: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
    } catch (e) {
      print('getDoctorNotification failed: $e');
    }
    return null;
  }

  Future<bool> discardDoctorNotification(int id) async {
    await chooseRole('Doctor');
    try {
      final response = await _dio.delete(
        'Doctor/NotificationApi/DiscardNotification/$id',
        options: Options(validateStatus: (status) => true),
      );

      print('DiscardNotification/$id: ${response.statusCode}');

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return true;
      }
    } catch (e) {
      print('discardDoctorNotification failed: $e');
    }
    return false;
  }

  // ==========================================
  // PatientApi
  // ==========================================

  Future<bool> adminRegisterPatient(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        'Admin/PatientApi/RegisterPatient',
        data: request.toMap(isDoctor: false),
        options: Options(validateStatus: (status) => true),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('adminRegisterPatient error: $e');
      return false;
    }
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
      String message = 'Failed to load patients (${response.statusCode})';
      if (response.statusCode == 302) {
        message = 'Session expired or unauthorized. Please log in again.';
      } else if (response.data is Map && response.data['message'] != null) {
        message = response.data['message'].toString();
      }
      throw message;
    } catch (e) {
      print('Admin GetAllPatients error: $e');
      rethrow;
    }
  }

  Future<bool> adminDeletePatient(int id) async {
    return _deleteRequest('Admin/PatientApi/DeletePatient/$id');
  }

  Future<bool> adminTogglePatientLock(int patientId) async {
    try {
      final response = await _dio.post(
        'Admin/PatientApi/TogglePatientLock/$patientId',
        options: Options(validateStatus: (status) => true),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }
      throw response.data?.toString() ?? 'Failed to toggle lock';
    } catch (e) {
      print('Admin TogglePatientLock error: $e');
      throw e.toString();
    }
  }

  Future<bool> adminResetPatientPassword(
    int patientId,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      final response = await _dio.post(
        'Admin/PatientApi/ResetPatientPassword/$patientId',
        data: {
          'NewPassword': newPassword,
          'ConfirmNewPassword': confirmPassword,
        },
        options: Options(validateStatus: (status) => true),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }
      throw response.data?.toString() ?? 'Failed to reset password';
    } catch (e) {
      print('Admin ResetPatientPassword error: $e');
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>?> adminGetPatient(int patientId) async {
    try {
      final response = await _dio.get(
        'Admin/PatientApi/GetPatient/$patientId',
        options: Options(validateStatus: (status) => true),
      );
      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return response.data as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      print('Admin GetPatient error: $e');
      return null;
    }
  }

  Future<bool> adminEditPatient(
    int patientId,
    Map<String, dynamic> data,
    String? imagePath,
  ) async {
    try {
      final formData = FormData.fromMap(data);

      if (imagePath != null && imagePath.isNotEmpty) {
        formData.files.add(
          MapEntry('ImageFile', await MultipartFile.fromFile(imagePath)),
        );
      }

      final response = await _dio.put(
        'Admin/PatientApi/EditPatient/$patientId',
        data: formData,
        options: Options(validateStatus: (status) => true),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }
      throw response.data?.toString() ?? 'Failed to edit patient';
    } catch (e) {
      print('Admin EditPatient error: $e');
      throw e.toString();
    }
  }

  Future<bool> adminDeletePatientImage(int patientId) async {
    return _deleteRequest('Admin/PatientApi/DeletePatientImage/$patientId');
  }

  // ==========================================
  // ProfileApi
  // ==========================================

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
      if (fullName != null && fullName.isNotEmpty) {
        mapData['FullName'] = fullName;
      }
      if (email != null && email.isNotEmpty) mapData['Email'] = email;
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        mapData['PhoneNumber'] = phoneNumber;
      }
      if (address != null && address.isNotEmpty) mapData['Address'] = address;
      if (gender != null && gender.isNotEmpty) mapData['Gender'] = gender;
      if (dateOfBirth != null && dateOfBirth.isNotEmpty) {
        mapData['DateOfBirth'] = dateOfBirth;
      }

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
        throw _parseApiError(response, 'Failed to edit profile');
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
        throw _parseApiError(response, 'Failed to edit profile');
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

  Future<bool> changePatientPassword(
    String currentPassword,
    String newPassword,
    String confirmNewPassword,
  ) async {
    try {
      final formData = FormData.fromMap({
        'CurrentPassword': currentPassword,
        'NewPassword': newPassword,
        'ConfirmPassword': confirmNewPassword,
      });
      final response = await _dio.post(
        'Patient/ProfileApi/ChangeAccountPassword',
        data: formData,
        options: Options(validateStatus: (status) => true),
      );
      print(
        'ChangePatientPassword Response: ${response.statusCode} - ${response.data}',
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        String errorMessage = 'Failed to change password';
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
      print('Failed to change password: $e');
      throw e.toString();
    }
  }

  Future<bool> deleteDoctorImage() async {
    return _deleteRequest('Doctor/ProfileApi/DeleteImage');
  }

  Future<bool> changeDoctorPassword(
    String currentPassword,
    String newPassword,
    String confirmNewPassword,
  ) async {
    try {
      final formData = FormData.fromMap({
        'CurrentPassword': currentPassword,
        'NewPassword': newPassword,
        'ConfirmPassword': confirmNewPassword,
      });
      final response = await _dio.post(
        'Doctor/ProfileApi/ChangeAccountPassword',
        data: formData,
        options: Options(validateStatus: (status) => true),
      );
      print(
        'ChangeDoctorPassword Response: ${response.statusCode} - ${response.data}',
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        String errorMessage = 'Failed to change password';
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
      print('Failed to change password: $e');
      throw e.toString();
    }
  }

  Future<bool> deleteDoctorAccount() async {
    return _deleteRequest('Doctor/ProfileApi/DeleteAccount');
  }

  // ==========================================
  // Other
  // ==========================================

  Future<List<dynamic>> getClinicSchedules(int clinicId) async {
    return getPatientClinicSchedules(clinicId: clinicId);
  }

  // ==========================================
  // DepartmentApi
  // ==========================================

  Future<List<dynamic>> getAllDepartments({int currentPage = 1}) async {
    try {
      final response = await _dio.get(
        'Admin/DepartmentApi/GetAllDepartments',
        queryParameters: {'currentPage': currentPage},
        options: Options(validateStatus: (status) => true),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return _extractListFromResponse(response.data);
      } else {
        throw _parseApiError(response, 'Failed to fetch departments');
      }
    } catch (e) {
      print('getAllDepartments error: $e');
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>?> getDepartment(int id) async {
    try {
      final response = await _dio.get(
        'Admin/DepartmentApi/GetDepartment/$id',
        options: Options(validateStatus: (status) => true),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map) {
          return Map<String, dynamic>.from(response.data);
        }
        return null;
      } else {
        throw _parseApiError(response, 'Failed to fetch department details');
      }
    } catch (e) {
      print('getDepartment error: $e');
      throw e.toString();
    }
  }

  Future<bool> createDepartment(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        'Admin/DepartmentApi/CreateDepartment',
        data: data,
        options: Options(validateStatus: (status) => true),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw _parseApiError(response, 'Failed to create department');
      }
    } catch (e) {
      print('createDepartment error: $e');
      throw e.toString();
    }
  }

  Future<bool> editDepartment(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        'Admin/DepartmentApi/EditDepartment/$id',
        data: data,
        options: Options(validateStatus: (status) => true),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw _parseApiError(response, 'Failed to update department');
      }
    } catch (e) {
      print('editDepartment error: $e');
      throw e.toString();
    }
  }

  Future<bool> deleteDepartment(int id) async {
    return _deleteRequest('Admin/DepartmentApi/DeleteDepartment/$id');
  }
}
