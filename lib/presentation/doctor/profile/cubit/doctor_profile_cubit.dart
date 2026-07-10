import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../data/repository/repository.dart';
import '../../../../../data/repository/shared_pref_controller.dart';
import 'doctor_profile_state.dart';

class DoctorProfileCubit extends Cubit<DoctorProfileState> {
  final Repository repository;
  final SharedPrefController sharedPrefController;

  DoctorProfileCubit({
    required this.repository,
    required this.sharedPrefController,
  }) : super(DoctorProfileInitial());

  int? currentDepartmentId;

  void getProfile() async {
    emit(DoctorProfileLoading());
    try {
      final profileData = await repository.getDoctorProfile();
      if (profileData != null) {
        print('=== Loaded Doctor Profile Data: $profileData ===');
        
        // Try parsing departmentId from various forms
        dynamic dId = profileData['departmentId'] ?? profileData['DepartmentId'];
        if (dId != null) {
          currentDepartmentId = dId is int ? dId : int.tryParse(dId.toString());
        }

        // If departmentId is still null, inspect departmentName or department field
        if (currentDepartmentId == null) {
          final dept = profileData['departmentName'] ?? profileData['DepartmentName'] ?? profileData['department'] ?? profileData['Department'];
          if (dept != null) {
            if (dept is Map) {
              final nestedId = dept['id'] ?? dept['Id'];
              if (nestedId != null) {
                currentDepartmentId = nestedId is int ? nestedId : int.tryParse(nestedId.toString());
              }
            } else if (dept is String) {
              final deptStr = dept.trim().toLowerCase();
              if (deptStr.contains('cardio')) {
                currentDepartmentId = 1;
              } else if (deptStr.contains('derm')) {
                currentDepartmentId = 2;
              } else if (deptStr.contains('neuro')) {
                currentDepartmentId = 3;
              } else if (deptStr.contains('ortho')) {
                currentDepartmentId = 4;
              } else if (deptStr.contains('pediatr')) {
                currentDepartmentId = 5;
              } else if (deptStr.contains('psych')) {
                currentDepartmentId = 6;
              } else if (deptStr.contains('ophth')) {
                currentDepartmentId = 7;
              }
            }
          }
        }
        
        print('=== Resolved currentDepartmentId: $currentDepartmentId ===');
        emit(DoctorProfileLoaded(profileData));
      } else {
        emit(DoctorProfileError('Failed to load profile data'));
      }
    } catch (e) {
      print('=== Error getting doctor profile: $e ===');
      emit(DoctorProfileError(e.toString()));
    }
  }

  void editProfile({
    String? fullName,
    String? phoneNumber,
    String? address,
    String? gender,
    String? dateOfBirth,
    int? departmentId,
    String? aboutMe,
    String? imagePath,
  }) async {
    emit(DoctorProfileLoading());
    try {
      final success = await repository.editDoctorProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        address: address,
        gender: gender,
        dateOfBirth: dateOfBirth,
        departmentId: departmentId ?? currentDepartmentId,
        aboutMe: aboutMe,
        imagePath: imagePath,
      );
      if (success) {
        if (fullName != null && fullName.isNotEmpty) {
           await sharedPrefController.saveName(fullName);
        }
        // جلب الـ profile من السيرفر مرة تانية وحفظ الصورة الجديدة
        try {
          final freshProfile = await repository.getDoctorProfile();
          if (freshProfile != null) {
            final rawImage = freshProfile['displayImageUrl']
                ?? freshProfile['imageUrl']
                ?? freshProfile['ImageUrl'];
            if (rawImage != null && rawImage.toString().isNotEmpty) {
              final raw = rawImage.toString();
              final fullUrl = raw.startsWith('http')
                  ? raw
                  : 'http://mediconnect.somee.com$raw';
              await sharedPrefController.saveImage(fullUrl);
              print('=== Saved new image after edit: $fullUrl ===');
            }
          }
        } catch (e) {
          print('Error fetching profile after edit: $e');
        }
        emit(DoctorProfileEditSuccess());
      } else {
        emit(DoctorProfileError('Failed to update profile'));
      }
    } catch (e) {
      emit(DoctorProfileError(e.toString()));
    }
  }

  void changePassword(String currentPassword, String newPassword, String confirmNewPassword) async {
    emit(DoctorProfilePasswordChangeLoading());
    try {
      final success = await repository.changeDoctorPassword(currentPassword, newPassword, confirmNewPassword);
      if (success) {
        emit(DoctorProfilePasswordChangeSuccess());
      } else {
        emit(DoctorProfilePasswordChangeError('Failed to change password'));
      }
    } catch (e) {
      emit(DoctorProfilePasswordChangeError(e.toString()));
    }
  }

  void deleteAccount() async {
    emit(DoctorProfileLoading());
    try {
      final success = await repository.deleteDoctorAccount();
      if (success) {
        await sharedPrefController.logout();
        emit(LogoutSuccess());
      } else {
        emit(DoctorProfileError('Failed to delete account'));
      }
    } catch (e) {
      emit(DoctorProfileError(e.toString()));
    }
  }
}
