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

      await SharedPrefsHelper.saveToken(
        response.token,
      );
      final role = response.roleTitle ?? 'unknown';

      // 4. حفظ الدور
      await SharedPrefsHelper.saveRole(
        role,
      );
      await SharedPrefsHelper.saveRole(role);

      print(
        '🔵 Login successful - Role: $role',
      );
      emit(
        LoginSuccess(
          response.token,
          role,
        ),
      );
    } catch (e) {
      print(
        '❌ Login error: $e',
      );

      emit(
        LoginError(
          e.toString(),
        ),
      );
    }
  }

  Future<void> logout() async {
    try {
      await repository.logout();

      await SharedPrefsHelper.clearToken();
      await SharedPrefsHelper.clearRole();
      await SharedPrefsHelper.clearUserId();

      emit(
        LogoutSuccess(),
      );
    } catch (e) {
      await SharedPrefsHelper.clearToken();
      await SharedPrefsHelper.clearRole();
      await SharedPrefsHelper.clearUserId();

      emit(
        LogoutSuccess(),
      );

      print(
        '⚠️ Logout error (ignored): $e',
      );
    }
  }
}
