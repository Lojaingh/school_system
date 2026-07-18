import 'package:dio/dio.dart';
import '../network/dio_client.dart';

class StudentProfileService {
  final Dio dio = DioClient.dio;

  Future<Response> getStudentProfile(int id) async {
    return await dio.get(
      "/student/$id",
    );
  }

  Future<Response> updateStudent(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await dio.patch(
      "/student/$id/update",
      queryParameters: data,
    );
  }
}
