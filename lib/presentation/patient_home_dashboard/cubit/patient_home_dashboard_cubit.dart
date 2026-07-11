import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduationproject/data/models/booking/booking_model.dart';
import 'package:graduationproject/data/models/schudule/doctorModel.dart';
import 'package:graduationproject/data/repository/repository.dart';
import 'package:graduationproject/data/repository/shared_pref_controller.dart';
import 'patient_home_dashboard_state.dart';

class PatientHomeDashboardCubit extends Cubit<PatientHomeDashboardState> {
  final Repository _repository;
  Repository get repository => _repository;
  final SharedPrefController _sharedPrefController = SharedPrefController();

  PatientHomeDashboardCubit(this._repository)
    : super(PatientHomeDashboardInitial());

  void getDashboardData({bool silent = false}) async {
    if (!silent) {
      emit(PatientHomeDashboardLoading());
    }
    try {
      // جيب البيانات من الـ API مباشرة
      final profileData = await _repository.getPatientProfile();

      String userName;
      String? imageUrl;

      if (profileData != null) {
        // الاسم من السيرفر
        final name =
            profileData['fullName'] ??
            profileData['FullName'] ??
            profileData['name'];

        // الصورة من السيرفر
        final rawImage =
            profileData['displayImageUrl'] ??
            profileData['imageUrl'] ??
            profileData['ImageUrl'] ??
            profileData['profileImageUrl'] ??
            profileData['ProfileImageUrl'] ??
            profileData['imagePath'];

        if (rawImage != null && rawImage.toString().isNotEmpty) {
          final raw = rawImage.toString();
          imageUrl = raw.startsWith('http')
              ? raw
              : 'http://mediconnect.somee.com$raw';
          // احفظ الصورة في SharedPrefs عشان تبقى متاحة في كل مكان
          await _sharedPrefController.saveImage(imageUrl);
        }

        if (name != null && name.toString().isNotEmpty) {
          await _sharedPrefController.saveName(name.toString());
          userName = name.toString();
        } else {
          // Fallback للاسم من SharedPrefs
          final storedName = await _sharedPrefController.getName();
          final email = await _sharedPrefController.getEmail();
          userName = storedName ?? email?.split('@').first ?? 'User';
        }
      } else {
        // Fallback كامل من SharedPrefs لو الـ API مش متاح
        final storedName = await _sharedPrefController.getName();
        final email = await _sharedPrefController.getEmail();
        final storedImage = await _sharedPrefController.getImage();
        userName = storedName ?? email?.split('@').first ?? 'User';
        imageUrl = storedImage;
      }

      final notifications = await _repository.getPatientNotifications();
      final lastViewedId = await _sharedPrefController
          .getLastViewedNotificationId();
      int unreadCount = 0;
      for (final n in notifications) {
        if (n is Map<String, dynamic>) {
          final idVal =
              n['id'] ??
              n['Id'] ??
              n['notificationId'] ??
              n['NotificationId'] ??
              0;
          final int id = idVal is int
              ? idVal
              : int.tryParse(idVal.toString()) ?? 0;
          final isRead =
              n['isRead'] ??
              n['IsRead'] ??
              n['isViewed'] ??
              n['IsViewed'] ??
              false;
          if (isRead == false && id > lastViewedId) {
            unreadCount++;
          }
        } else if (n is BookingModel) {
          if (n.notificationUnread) {
            unreadCount++;
          }
        } else {
          // If fallback local store (other types)
          unreadCount++;
        }
      }

      dynamic nextAppt;
      try {
        final appointments = await _repository.getPatientAppointments();

        // Inject doctor images into appointments
        try {
          final doctors = await _repository.getPatientDoctors();
          for (var appt in appointments) {
            if (appt is Map) {
              final docIdStr = appt['doctorId'] ?? appt['doctor']?['id'];
              final docId = docIdStr != null
                  ? (docIdStr is int
                        ? docIdStr
                        : int.tryParse(docIdStr.toString()) ?? 0)
                  : 0;
              DoctorModel? matchedDoc;
              if (docId != 0) {
                try {
                  matchedDoc = doctors.firstWhere((d) => d.id == docId);
                } catch (_) {}
              } else {
                final apptClinic =
                    (appt['clinicName'] ?? appt['specialty'] ?? '')
                        .toString()
                        .toLowerCase()
                        .trim();
                if (apptClinic.isNotEmpty) {
                  try {
                    matchedDoc = doctors.firstWhere((d) {
                      final dDept = (d.departmentName ?? '')
                          .toLowerCase()
                          .trim();
                      final dDesc = (d.departmentDescription ?? '')
                          .toLowerCase()
                          .trim();
                      return (dDept.isNotEmpty && dDept == apptClinic) ||
                          (dDesc.isNotEmpty && dDesc == apptClinic);
                    });
                  } catch (_) {}
                }
              }

              if (matchedDoc != null) {
                if (matchedDoc.imageUrl != null &&
                    matchedDoc.imageUrl!.isNotEmpty) {
                  appt['doctorImageUrl'] = matchedDoc.imageUrl;
                }
                if (matchedDoc.fullName.isNotEmpty &&
                    matchedDoc.fullName != 'Doctor') {
                  appt['realDoctorName'] = matchedDoc.fullName;
                }
              }
            }
          }
        } catch (_) {}

        final upcoming = appointments.where((a) {
          final status =
              ((a is Map ? a['status'] : (a as dynamic).status) ?? '')
                  .toString()
                  .toLowerCase();
          if (status.contains('cancel')) return false;
          if (status.contains('reject')) return false;
          if (status.contains('denied')) return false;
          if (status.contains('complet')) return false;
          return true;
        }).toList();
        // No need to validate one by one with getPatientAppointment because repository.getPatientAppointments() already returns valid ones.
        if (upcoming.isNotEmpty) {
          nextAppt = upcoming.first;
        }
      } catch (e) {
        print('Error getting dashboard appointments: $e');
      }

      final healthMetrics = await _repository.getPatientHealthMetrics();
      var meds = await _repository.getPatientMedications();

      if (isClosed) return;
      emit(
        PatientHomeDashboardSuccess(
          userName: userName,
          imageUrl: imageUrl,
          unreadNotifications: unreadCount,
          nextAppointment: nextAppt,
          heartRate: healthMetrics['heartRate'] ?? '0',
          bloodPressure: healthMetrics['bloodPressure'] ?? '0/0',
          medications: meds,
        ),
      );
    } catch (e) {
      // Fallback لو حصل خطأ
      try {
        final storedName = await _sharedPrefController.getName();
        final email = await _sharedPrefController.getEmail();
        final storedImage = await _sharedPrefController.getImage();
        final userName = storedName ?? email?.split('@').first ?? 'User';
        final notifications = await _repository.getPatientNotifications();
        final lastViewedId = await _sharedPrefController
            .getLastViewedNotificationId();
        int unreadCount = 0;
        for (final n in notifications) {
          if (n is Map<String, dynamic>) {
            final idVal =
                n['id'] ??
                n['Id'] ??
                n['notificationId'] ??
                n['NotificationId'] ??
                0;
            final int id = idVal is int
                ? idVal
                : int.tryParse(idVal.toString()) ?? 0;
            final isRead =
                n['isRead'] ??
                n['IsRead'] ??
                n['isViewed'] ??
                n['IsViewed'] ??
                false;
            if (isRead == false && id > lastViewedId) {
              unreadCount++;
            }
          } else if (n is BookingModel) {
            if (n.notificationUnread) {
              unreadCount++;
            }
          } else {
            unreadCount++;
          }
        }
        dynamic nextAppt;
        try {
          final appointments = await _repository.getPatientAppointments();
          final upcoming = appointments.where((a) {
            final status =
                ((a is Map ? a['status'] : (a as dynamic).status) ?? '')
                    .toString()
                    .toLowerCase();
            if (status.contains('cancel')) return false;
            if (status.contains('reject')) return false;
            if (status.contains('denied')) return false;
            if (status.contains('complet')) return false;
            return true;
          }).toList();
          if (upcoming.isNotEmpty) {
            nextAppt = upcoming.first;
          }
        } catch (_) {}

        final healthMetrics = await _repository.getPatientHealthMetrics();
        var meds = await _repository.getPatientMedications();

        if (isClosed) return;
        emit(
          PatientHomeDashboardSuccess(
            userName: userName,
            imageUrl: storedImage,
            unreadNotifications: unreadCount,
            nextAppointment: nextAppt,
            heartRate: healthMetrics['heartRate'] ?? '72',
            bloodPressure: healthMetrics['bloodPressure'] ?? '120/80',
            medications: meds,
          ),
        );
      } catch (_) {
        if (isClosed) return;
        emit(PatientHomeDashboardError(e.toString()));
      }
    }
  }

  Future<void> deleteMedication(int index) async {
    try {
      final currentMeds = await _repository.getPatientMedications();
      if (index >= 0 && index < currentMeds.length) {
        currentMeds.removeAt(index);
        await _repository.savePatientMedications(currentMeds);
        getDashboardData(silent: true);
      }
    } catch (e) {
      print('Error deleting medication: \$e');
    }
  }
}
