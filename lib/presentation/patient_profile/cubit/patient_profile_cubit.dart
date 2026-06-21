import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repository/repository.dart';
import '../../../data/repository/shared_pref_controller.dart';
import 'patient_profile_state.dart';

class PatientProfileCubit extends Cubit<PatientProfileState> {
  final Repository repository;
  final SharedPrefController sharedPrefController;

  PatientProfileCubit({
    required this.repository,
    required this.sharedPrefController,
  }) : super(PatientProfileInitial());

  void getProfileData() async {
    emit(PatientProfileLoading());
    try {
      final profileData = await repository.getPatientProfile();
      if (profileData != null) {
        print('=== Loaded Patient Profile Data: $profileData ===');

        // استخراج الاسم
        final name =
            profileData['fullName'] ??
            profileData['FullName'] ??
            profileData['name'] ??
            (await sharedPrefController.getName()) ??
            'User';

        // استخراج الصورة
        final rawImage =
            profileData['displayImageUrl'] ??
            profileData['imageUrl'] ??
            profileData['ImageUrl'] ??
            profileData['profileImageUrl'] ??
            profileData['ProfileImageUrl'] ??
            profileData['imagePath'];
        String? imageUrl;
        if (rawImage != null && rawImage.toString().isNotEmpty) {
          final raw = rawImage.toString();
          imageUrl = raw.startsWith('http')
              ? raw
              : 'http://medicalsystem111.runasp.net$raw';
          await sharedPrefController.saveImage(imageUrl);
        }

        // تحديث الاسم في SharedPref
        if (name != null && name.isNotEmpty) {
          await sharedPrefController.saveName(name);
        }

        // استخراج باقي الحقول
        final email =
            profileData['email'] ?? profileData['Email'] ?? '';
        final phone =
            profileData['phoneNumber'] ?? profileData['PhoneNumber'] ?? '';
        final address =
            profileData['address'] ?? profileData['Address'] ?? '';
        final gender =
            profileData['gender'] ?? profileData['Gender'] ?? '';
        final rawDob =
            profileData['dateOfBirth'] ?? profileData['DateOfBirth'] ?? '';
        final dob = rawDob.toString().contains('T')
            ? rawDob.toString().split('T').first
            : rawDob.toString();

        emit(PatientProfileSuccess(
          name: name,
          email: email,
          phone: phone,
          address: address,
          gender: gender,
          imageUrl: imageUrl,
          patientId: 'PT-${profileData['id'] ?? '000000'}',
          age: _calcAge(dob),
          bloodType: profileData['bloodType'] ?? profileData['BloodType'] ?? 'N/A',
          dateOfBirth: dob,
          medicalHistory: profileData['medicalHistory'] ?? profileData['MedicalHistory'] ?? 'N/A',
          allergies: profileData['allergies'] ?? profileData['Allergies'] ?? 'N/A',
        ));
      } else {
        // Fallback للبيانات المحفوظة محلياً لو الـ API مش متاح
        final email = await sharedPrefController.getEmail() ?? 'N/A';
        final storedName = await sharedPrefController.getName();
        final storedImage = await sharedPrefController.getImage();
        final name = storedName ?? email.split('@').first;
        emit(PatientProfileSuccess(
          name: name,
          email: email,
          phone: '',
          address: '',
          gender: '',
          imageUrl: storedImage,
          patientId: 'N/A',
          age: 'N/A',
          bloodType: 'N/A',
          dateOfBirth: '',
          medicalHistory: 'N/A',
          allergies: 'N/A',
        ));
      }
    } catch (e) {
      print('=== PatientProfileCubit error: $e ===');
      emit(PatientProfileError(e.toString()));
    }
  }

  String _calcAge(String dob) {
    if (dob.isEmpty) return 'N/A';
    try {
      final d = DateTime.parse(dob);
      final now = DateTime.now();
      int age = now.year - d.year;
      if (now.month < d.month || (now.month == d.month && now.day < d.day)) age--;
      return age.toString();
    } catch (_) {
      return 'N/A';
    }
  }

  void logout() async {
    emit(PatientProfileLoading());
    try {
      final response = await repository.logout();
      if (response.status) {
        await sharedPrefController.logout();
        emit(LogoutSuccess());
      } else {
        emit(PatientProfileError(response.message));
      }
    } catch (e) {
      emit(PatientProfileError(e.toString()));
    }
  }

  void deleteImage() async {
    emit(PatientProfileLoading());
    try {
      final success = await repository.deletePatientImage();
      if (success) {
        emit(PatientProfileImageDeleted());
        getProfileData();
      } else {
        emit(PatientProfileError('Failed to delete image'));
      }
    } catch (e) {
      emit(PatientProfileError(e.toString()));
    }
  }

  void deleteAccount() async {
    emit(PatientProfileLoading());
    try {
      final success = await repository.deletePatientAccount();
      if (success) {
        await sharedPrefController.logout();
        emit(LogoutSuccess());
      } else {
        emit(PatientProfileError('Failed to delete account'));
      }
    } catch (e) {
      emit(PatientProfileError(e.toString()));
    }
  }

  void editProfile({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? address,
    String? gender,
    String? dateOfBirth,
    String? imagePath,
  }) async {
    emit(PatientProfileLoading());
    try {
      final success = await repository.editPatientProfile(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        address: address,
        gender: gender,
        dateOfBirth: dateOfBirth,
        imagePath: imagePath,
      );
      if (success) {
        if (fullName != null && fullName.isNotEmpty) {
           await sharedPrefController.saveName(fullName);
        }
        if (email != null && email.isNotEmpty) {
           await sharedPrefController.saveEmail(email);
        }
        emit(PatientProfileEditSuccess());
        // نستنى frame واحد عشان الـ edit screen يعمل pop الأول
        await Future.delayed(const Duration(milliseconds: 100));
        getProfileData();
      } else {
        emit(PatientProfileError('Failed to update profile'));
      }
    } catch (e) {
      emit(PatientProfileError(e.toString()));
    }
  }
}
