import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduationproject/data/repository/repository.dart';
import 'package:graduationproject/data/repository/shared_pref_controller.dart';
import 'patient_home_dashboard_state.dart';

class PatientHomeDashboardCubit extends Cubit<PatientHomeDashboardState> {
  final Repository _repository;
  final SharedPrefController _sharedPrefController = SharedPrefController();

  PatientHomeDashboardCubit(this._repository)
      : super(PatientHomeDashboardInitial());

  void getDashboardData() async {
    emit(PatientHomeDashboardLoading());
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
              : 'http://medicalsystem111.runasp.net$raw';
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

      emit(PatientHomeDashboardSuccess(
        userName: userName,
        imageUrl: imageUrl,
        medications: const [
          {'title': 'Amoxicillin', 'subtitle': '500mg • 1 pill/day', 'badge': 'Active'},
          {'title': 'Lisinopril', 'subtitle': '10mg • 1 pill/day', 'badge': 'Refill'},
        ],
      ));
    } catch (e) {
      // Fallback لو حصل خطأ
      try {
        final storedName = await _sharedPrefController.getName();
        final email = await _sharedPrefController.getEmail();
        final storedImage = await _sharedPrefController.getImage();
        final userName = storedName ?? email?.split('@').first ?? 'User';
        emit(PatientHomeDashboardSuccess(
          userName: userName,
          imageUrl: storedImage,
          medications: const [
            {'title': 'Amoxicillin', 'subtitle': '500mg • 1 pill/day', 'badge': 'Active'},
            {'title': 'Lisinopril', 'subtitle': '10mg • 1 pill/day', 'badge': 'Refill'},
          ],
        ));
      } catch (_) {
        emit(PatientHomeDashboardError(e.toString()));
      }
    }
  }
}
