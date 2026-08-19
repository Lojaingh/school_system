import 'package:dio/dio.dart';
import '../network/dio_client.dart';
import '../model/staff_model.dart';

class StaffService {
  final Dio dio = DioClient.dio;
  Future<Response> registerStaff(StaffModel staff) async {
    return await dio.post(
      '/add/staff',
      data: staff.toJson(),
    );
  }
  Future<Response> registerTeacher(StaffModel staff) async {
    return await dio.post(
      '/add/teacher',
      data: staff.toTeacherJson(),
    );
  }
  Future<Response> getSubjects() async {
    return await dio.get('/subjects');
  }
}
