abstract class StaffRegisterState {}

class StaffRegisterInitial extends StaffRegisterState {}

class StaffRegisterLoading extends StaffRegisterState {}

class StaffRegisterSuccess extends StaffRegisterState {
  final String message;

  StaffRegisterSuccess(this.message);
}

class TeacherRegisterSuccess extends StaffRegisterState {
  final String username;
  final String password;

  TeacherRegisterSuccess({
    required this.username,
    required this.password,
  });
}

class StaffRegisterError extends StaffRegisterState {
  final String message;

  StaffRegisterError(this.message);
}
