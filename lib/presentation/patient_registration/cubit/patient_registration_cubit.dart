import 'package:flutter_bloc/flutter_bloc.dart';
import 'patient_registration_state.dart';

class PatientRegistrationCubit extends Cubit<PatientRegistrationState> {
  PatientRegistrationCubit() : super(PatientRegistrationInitial());

  final List<String> _allergies = [];
  final List<String> _conditions = [];

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
}
