abstract class RoleSelectionState {}

class RoleSelectionInitial extends RoleSelectionState {}

class RoleSelectionLoading extends RoleSelectionState {}

class RoleSelectionChanged extends RoleSelectionState {
  final UserRole selectedRole;
  RoleSelectionChanged(this.selectedRole);
}

class RoleSelectionSuccess extends RoleSelectionState {
  final UserRole role;
  RoleSelectionSuccess(this.role);
}

class RoleSelectionError extends RoleSelectionState {
  final String message;
  RoleSelectionError(this.message);
}

enum UserRole { patient, doctor, none }
