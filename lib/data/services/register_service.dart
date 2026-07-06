import 'package:dio/dio.dart';
import '../network/dio_client.dart';
import '../model/student_model.dart';

class RegisterService {
  final Dio dio = DioClient.dio;

  Future<Response> register(StudentModel student) async {
    return await dio.post(
      '/add/student',
      data: student.toJson(),
    );
  }
}
