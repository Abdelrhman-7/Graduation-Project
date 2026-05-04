import 'package:flutter_bloc/flutter_bloc.dart';
import 'role_selection_state.dart';

class RoleSelectionCubit extends Cubit<RoleSelectionState> {
  RoleSelectionCubit() : super(RoleSelectionInitial());

  UserRole currentRole = UserRole.none;

  void selectRole(UserRole role) {
    currentRole = role;
    emit(RoleSelectionChanged(currentRole));
  }
}
