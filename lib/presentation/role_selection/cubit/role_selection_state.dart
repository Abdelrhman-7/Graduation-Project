abstract class RoleSelectionState {}

class RoleSelectionInitial extends RoleSelectionState {}

class RoleSelectionChanged extends RoleSelectionState {
  final UserRole selectedRole;

  RoleSelectionChanged(this.selectedRole);
}

enum UserRole { patient, doctor, none }
