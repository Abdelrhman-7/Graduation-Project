import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduationproject/data/repository/shared_pref_controller.dart';
import 'package:graduationproject/data/repository/repository.dart';
import 'doctor_home_state.dart';

class DoctorHomeCubit extends Cubit<DoctorHomeState> {
  final SharedPrefController _sharedPrefController = SharedPrefController();
  final Repository _repository;

  DoctorHomeCubit(this._repository) : super(DoctorHomeInitial());

  void getDoctorHomeData() async {
    emit(DoctorHomeLoading());
    try {
      // Refresh name and image from the server
      String? apiImageUrl;
      String? apiName;
      try {
        final profile = await _repository.getDoctorProfile();
        if (profile != null) {
          // Debug: print all keys from the API response
          print('=== DoctorProfile API keys: ${profile.keys.toList()} ===');
          print('=== DoctorProfile full data: $profile ===');

          apiName = profile['fullName'] ?? profile['FullName'] ?? profile['name'] ?? profile['Name'];

          // الكي الصح هو displayImageUrl وبيرجع path نسبي
          final rawImage = profile['displayImageUrl']
              ?? profile['imageUrl']
              ?? profile['ImageUrl']
              ?? profile['profileImageUrl']
              ?? profile['ProfileImageUrl']
              ?? profile['imagePath']
              ?? profile['ImagePath']
              ?? profile['image']
              ?? profile['Image'];

          if (rawImage != null && rawImage.toString().isNotEmpty) {
            // لو بيبدأ بـ / يبقى path نسبي - نضيف الـ base domain
            final raw = rawImage.toString();
            apiImageUrl = raw.startsWith('http')
                ? raw
                : 'http://medicalsystem111.runasp.net$raw';
          }

          if (apiName != null && apiName.isNotEmpty) {
            await _sharedPrefController.saveName(apiName);
          }
          if (apiImageUrl != null && apiImageUrl.isNotEmpty) {
            await _sharedPrefController.saveImage(apiImageUrl);
          }
        }
      } catch (e) {
        print('Error refreshing doctor profile in Home Cubit: $e');
      }

      final String? storedName = await _sharedPrefController.getName();
      final String? storedImage = await _sharedPrefController.getImage();
      final String? email = await _sharedPrefController.getEmail();
      
      String doctorName = apiName ?? storedName ?? 'Dr. Sarah Wilson';
      // استخدم الصورة من الـ API مباشرة لو موجودة، وإلا من SharedPreferences
      String? imageUrl = apiImageUrl ?? storedImage;
      
      if (email == 'abdo85@gmail.com' && storedName == null && apiName == null) {
        doctorName = 'Dr. Abdo';
      }

      print('=== Final imageUrl for Home: $imageUrl ===');

      await Future.delayed(const Duration(milliseconds: 800));
      emit(DoctorHomeSuccess(
        doctorName: doctorName,
        imageUrl: imageUrl,
        specialty: 'Cardiologist',
        patientsToday: 12,
        upNextAppointment: {
          'patientName': 'Mark Thompson',
          'time': '10:30 AM',
          'type': 'Video Consultation',
          'status': 'In 5 min',
        },
        patientRequests: [
          {
            'patientName': 'Emily Davis',
            'type': 'Refill Request',
            'details': 'Lisinopril 10mg',
            'time': '2h ago',
          },
          {
            'patientName': 'James Miller',
            'type': 'Lab Result Review',
            'details': 'CBC & Lipid Panel',
            'time': '4h ago',
          }
        ],
        todaySchedule: [
          {'time': '09:00 AM', 'title': 'Routine Checkup', 'patient': 'John Doe'},
          {'time': '10:00 AM', 'title': 'Follow-up', 'patient': 'Jane Smith'},
          {'time': '12:00 PM', 'title': 'Lunch Break', 'isBreak': true},
          {'time': '01:30 PM', 'title': 'Post-surgery Follow-up', 'patient': 'Robert Brown'},
        ],
      ));
    } catch (e) {
      emit(DoctorHomeError(e.toString()));
    }
  }
}
