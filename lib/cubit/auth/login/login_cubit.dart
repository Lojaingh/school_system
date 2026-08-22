import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/data/repository/auth_repository.dart';
import 'package:school_management/utils/shared_prefs_helper.dart';
import 'login_state.dart';
import 'package:dio/dio.dart';

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

      await SharedPrefsHelper.saveRole(role);

      print('🔵 Login successful - Role: $role');

      emit(
        LoginSuccess(
          response.token,
          role,
        ),
      );
    } catch (e) {
      print('❌ Login error: $e');

      String message = "Something went wrong. Please try again.";

      if (e is DioException) {
        final data = e.response?.data;

        if (e.response?.statusCode == 401) {
          message = data is Map
              ? data['message'] ?? "Username or password is incorrect"
              : "Username or password is incorrect";
        }
      } else {
        // إذا الريبو حولها لـ Exception عادية
        if (e.toString().contains("Username or password is incorrect")) {
          message = "Username or password is incorrect";
        }
      }

      emit(
        LoginError(message),
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
