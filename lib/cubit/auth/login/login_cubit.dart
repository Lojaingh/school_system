import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/data/repository/auth_repository.dart';
import 'package:school_management/utils/shared_prefs_helper.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository repository;

  LoginCubit(this.repository) : super(LoginInitial());

  Future<void> login(
    String userName,
    String password,
  ) async {
    try {
      emit(LoginLoading());

      final response = await repository.login(
        userName,
        password,
      );
      await SharedPrefsHelper.saveToken(response.token);

      emit(LoginSuccess(response.token));
    } catch (e) {
      emit(LoginError(e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      await repository.logout();
      await SharedPrefsHelper.clearToken();
      emit(LogoutSuccess());
    } catch (e) {
      emit(LoginError(e.toString()));
    }
  }
}
