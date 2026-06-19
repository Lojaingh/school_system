import 'package:school_management/data/model/staff_model.dart';
import 'package:school_management/data/services/staff_service.dart';
import 'package:dio/dio.dart';

class StaffRepository {
  final StaffService service;

  StaffRepository(this.service);

  Future<String> registerStaff(StaffModel staff) async {
    try {
      final response = await service.registerStaff(staff);
      print('STATUS: ${response.statusCode}');
      print('DATA: ${response.data}');

      if (response.data is Map<String, dynamic>) {
        return response.data['message'] ?? 'Success';
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      print('DIO ERROR STATUS: ${e.response?.statusCode}');
      print('DIO ERROR DATA: ${e.response?.data}');
      throw Exception('Failed to register staff: ${e.response?.data}');
    }
  }
}
