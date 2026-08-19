import 'package:dio/dio.dart';
import 'package:school_management/data/model/staff_model.dart';
import 'package:school_management/data/services/staff_service.dart';

class StaffRepository {
  final StaffService service;

  StaffRepository(this.service);
  Future<String> registerStaff(StaffModel staff) async {
    try {
      final response = await service.registerStaff(staff);

      print('STAFF STATUS: ${response.statusCode}');
      print('STAFF DATA: ${response.data}');

      if (response.data is Map<String, dynamic>) {
        return response.data['message'] ?? 'Success';
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      print('DIO ERROR STATUS: ${e.response?.statusCode}');
      print('DIO ERROR DATA: ${e.response?.data}');

      throw Exception(
        'Failed to register staff: ${e.response?.data}',
      );
    }
  }

  Future<Map<String, String>> registerTeacher(
    StaffModel staff,
  ) async {
    try {
      final response = await service.registerTeacher(staff);

      print('TEACHER STATUS: ${response.statusCode}');
      print('TEACHER DATA: ${response.data}');

      final data = response.data['data'];

      return {
        'username': data['username'].toString(),
        'password': response.data['plain_password'].toString(),
      };
    } on DioException catch (e) {
      print('TEACHER ERROR STATUS: ${e.response?.statusCode}');
      print('TEACHER ERROR DATA: ${e.response?.data}');

      throw Exception(
        'Failed to register teacher: ${e.response?.data}',
      );
    }
  }
  Future<List<Map<String, dynamic>>> getSubjects() async {
    try {
      final response = await service.getSubjects();

      print('SUBJECTS STATUS: ${response.statusCode}');
      print('SUBJECTS DATA: ${response.data}');

      final List data = response.data['data'];

      return data
          .map(
            (subject) => {
              'id': subject['id'],
              'name': subject['name'],
            },
          )
          .toList();
    } on DioException catch (e) {
      print('SUBJECTS ERROR STATUS: ${e.response?.statusCode}');
      print('SUBJECTS ERROR DATA: ${e.response?.data}');

      throw Exception(
        'Failed to load subjects: ${e.response?.data}',
      );
    }
  }
}
