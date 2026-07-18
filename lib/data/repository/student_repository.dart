import 'package:dio/dio.dart';
import 'package:school_management/data/services/student_service.dart';
import 'package:school_management/data/model/student_profile_model.dart';

class StudentRepository {
  final StudentService service;

  StudentRepository(this.service);

  Future<List<StudentProfileModel>> getStudents(int roleId) async {
    try {
      final response = await service.getStudents(roleId);

      final List data = response.data['data'];

      return data.map((e) => StudentProfileModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data.toString() ?? e.toString());
    }
  }

  Future<void> deleteStudent(int id) async {
    await service.deleteStudent(id);
  }
}
