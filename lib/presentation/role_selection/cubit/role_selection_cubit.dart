import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repository/repository.dart';
import 'role_selection_state.dart';

class RoleSelectionCubit extends Cubit<RoleSelectionState> {
  final Repository _repository;
  RoleSelectionCubit(this._repository) : super(RoleSelectionInitial());

  UserRole currentRole = UserRole.none;

  void selectRole(UserRole role) {
    currentRole = role;
    emit(RoleSelectionChanged(currentRole));
  }

  Future<void> confirmRole() async {
    if (currentRole == UserRole.none) return;

    emit(RoleSelectionLoading());
    try {
      final roleStr = currentRole == UserRole.patient ? 'Patient' : 'Doctor';
      final success = await _repository.chooseRole(roleStr);
      
      if (success) {
        emit(RoleSelectionSuccess(currentRole));
      } else {
        // Even if API fails, we might want to proceed for now if it's just for UI
        // but user asked for the API, so we show error.
        emit(RoleSelectionError('Failed to confirm role on server.'));
      }
    } catch (e) {
      emit(RoleSelectionError(e.toString()));
    }
  }
}
