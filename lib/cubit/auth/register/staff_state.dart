abstract class StaffRegisterState {}

class StaffRegisterInitial extends StaffRegisterState {}

class StaffRegisterLoading extends StaffRegisterState {}

class StaffRegisterSuccess extends StaffRegisterState {
  final String message;

  StaffRegisterSuccess(this.message);
}

class StaffRegisterError extends StaffRegisterState {
  final String message;

  StaffRegisterError(this.message);
}
