abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String token;
  final String role;

  LoginSuccess(this.token, this.role);
}

class LoginError extends LoginState {
  final String message;

  LoginError(this.message);
}

class LogoutSuccess extends LoginState {}
