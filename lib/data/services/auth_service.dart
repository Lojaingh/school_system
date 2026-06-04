import 'package:dio/dio.dart';

class AuthService {
  final Dio dio;

  AuthService(this.dio);

  Future<Response> login({
    required String userName,
    required String password,
  }) async {
    return await dio.post(
      '/login',
      data: {
        "user_name": userName,
        "password": password,
      },
    );
  }
}
