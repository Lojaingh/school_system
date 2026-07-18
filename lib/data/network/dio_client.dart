import 'package:dio/dio.dart';
import 'package:school_management/utils/shared_prefs_helper.dart';

class DioClient {
<<<<<<< HEAD
  static late Dio dio;

  static Future<void> init() async {
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://127.0.0.1:8000/api/v1',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SharedPrefsHelper.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            SharedPrefsHelper.clearToken();
          }
          return handler.next(error);
        },
      ),
    );
  }
=======
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api/v1',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization':
            'Bearer 1|Eogvj31z6VKcr1uTWp9rOhytQ6mb0xxibrKnRBV57f346347',
      },
    ),
  );
>>>>>>> lana
}
