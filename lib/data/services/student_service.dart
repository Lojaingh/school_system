import 'package:dio/dio.dart';
import '../network/dio_client.dart';

class StudentService {
  final Dio dio = DioClient.dio;

  Future<Response> getStudents(int roleId) async {
    return await dio.get(
      '/staff/all',
      queryParameters: {
        'role_id': roleId,
        'per_page': 100,
      },
    );
  }

  Future<Response> deleteStudent(int id) async {
    return await dio.delete('/student/$id');
  }
}
