import 'package:dio/dio.dart';
import 'package:school_management/data/model/subject_model.dart';
import 'package:school_management/data/services/subject_service.dart';

class SubjectRepository {
  final SubjectService subjectService;

  SubjectRepository(this.subjectService);
  Future<String> addSubject(SubjectModel subject) async {
    try {
      final response = await subjectService.addSubject(subject);

      print("STATUS: ${response.statusCode}");
      print("DATA: ${response.data}");

      return response.data['message'];
    } on DioException catch (e) {
      print("STATUS: ${e.response?.statusCode}");
      print("DATA: ${e.response?.data}");

      rethrow;
    }
  }

  Future<List<dynamic>> getSubjects() async {
    try {
      final response = await subjectService.getSubjects();
      return response.data['data'];
    } on DioException catch (e) {
      throw Exception(e.response?.data.toString() ?? e.toString());
    }
  }

  Future<Map<String, dynamic>> getSubject(int id) async {
    try {
      final response = await subjectService.getSubject(id);
      return response.data['data'];
    } on DioException catch (e) {
      throw Exception(e.response?.data.toString() ?? e.toString());
    }
  }

  Future<String> updateSubject(int id, SubjectModel subject) async {
    try {
      final response = await subjectService.updateSubject(id, subject);
      return response.data['message'] ?? "Updated";
    } on DioException catch (e) {
      throw Exception(e.response?.data.toString() ?? e.toString());
    }
  }

  Future<String> deleteSubject(int id) async {
    try {
      final response = await subjectService.deleteSubject(id);
      return response.data['message'] ?? "Deleted";
    } on DioException catch (e) {
      throw Exception(e.response?.data.toString() ?? e.toString());
    }
  }
}
