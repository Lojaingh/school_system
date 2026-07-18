import 'package:dio/dio.dart';
import 'package:school_management/data/model/student_profile_model.dart';
import 'package:school_management/data/services/student_profile_service.dart';

class StudentProfileRepository {
  final StudentProfileService service;

  StudentProfileRepository(this.service);

  Future<StudentProfileModel> getStudentProfile(int id) async {
    try {
      final response = await service.getStudentProfile(id);

      final data = response.data["data"];

      return StudentProfileModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data.toString() ?? e.toString(),
      );
    }
  }

  Future<void> updateStudent(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      await service.updateStudent(id, data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data.toString() ?? e.toString(),
      );
    }
  }
}
