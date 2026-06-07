import 'package:dio/dio.dart';
import 'package:school_management/data/services/register_service.dart';
import '../model/student_model.dart';

class RegisterRepository {
  final RegisterService studentService;

  RegisterRepository(this.studentService);

  Future<String> register(StudentModel student) async {
    try {
      final response = await studentService.register(student);

      print('STATUS CODE: ${response.statusCode}');
      print('RESPONSE DATA: ${response.data}');

      return response.data['message'] ?? 'Success';
    } on DioException catch (e) {
      print('STATUS: ${e.response?.statusCode}');
      print('DATA: ${e.response?.data}');

      throw Exception(e.response?.data.toString() ?? e.toString());
    }
  }
}
