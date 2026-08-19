abstract class RegisterState {}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {
  final String username;
  final String password;

  RegisterSuccess({
    required this.username,
    required this.password,
  });
}

class RegisterError extends RegisterState {
  final String message;

  RegisterError(this.message);
}
