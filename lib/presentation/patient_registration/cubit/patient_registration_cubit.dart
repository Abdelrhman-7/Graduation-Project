import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/api/api_manager.dart';
import '../../../data/models/register_model.dart';
import 'patient_registration_state.dart';

class PatientRegistrationCubit extends Cubit<PatientRegistrationState> {
  final ApiManager _apiService;

  PatientRegistrationCubit(this._apiService) : super(PatientRegistrationInitial());

  String fullName = 'Abdo';
  String email = 'abdo77@gmail.com';
  String dateOfBirth = '';
  String phoneNumber = '';
  String address = '';
  String gender = 'Male';
  String password = '123456789@#\$Abdo';
  String? imagePath;

  final List<String> _allergies = [];
  final List<String> _conditions = [];

  void updateFullName(String value) => fullName = value;
  void updateEmail(String value) => email = value;
  void updateDateOfBirth(String value) => dateOfBirth = value;
  void updatePhoneNumber(String value) => phoneNumber = value;
  void updateAddress(String value) => address = value;
  void updateGender(String value) => gender = value;
  void updatePassword(String value) => password = value;
  void updateImagePath(String? value) => imagePath = value;

  void toggleAllergy(String allergy) {
    if (_allergies.contains(allergy)) {
      _allergies.remove(allergy);
    } else {
      _allergies.add(allergy);
    }
    _emitUpdate();
  }

  void toggleCondition(String condition) {
    if (_conditions.contains(condition)) {
      _conditions.remove(condition);
    } else {
      _conditions.add(condition);
    }
    _emitUpdate();
  }

  bool hasAllergy(String allergy) => _allergies.contains(allergy);
  bool hasCondition(String condition) => _conditions.contains(condition);

  void _emitUpdate() {
    emit(
      PatientRegistrationUpdated(
        allergies: List.from(_allergies),
        conditions: List.from(_conditions),
      ),
    );
  }

  Future<void> register() async {
    emit(PatientRegistrationLoading());
    try {
      final request = RegisterRequest(
        fullName: fullName,
        userName: fullName.replaceAll(' ', ''), // ASP.NET Identity requires unique UserName without spaces
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        address: address,
        gender: gender,
        dateOfBirth: dateOfBirth,
        imageFile: imagePath,
      );

      final result = await _apiService.register(request);

      if (result.status == true) {
        emit(PatientRegistrationSuccess(result.message));
      } else {
        emit(PatientRegistrationError(result.message ?? 'Registration failed'));
      }
    } catch (e) {
      emit(PatientRegistrationError(e.toString()));
    }
  }
}
