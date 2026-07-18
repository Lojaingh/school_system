import 'package:dio/dio.dart';

class AuthService {
  final Dio dio;

  AuthService(this.dio);

  Future<Response> login({
    required String username,
    required String password,
  }) async {
    return await dio.post(
      '/login',
      data: {
        "user_name": username,
        "password": password,
      },
    );
  }

  Future<Response> logout() async {
    return await dio.post('/logout');
  }
}
