import 'package:dio/dio.dart';
import '../network/dio_client.dart';

class StaffProfileService {
  final Dio dio = DioClient.dio;

  Future<Response> getStaff({int? roleId}) async {
    return await dio.get(
      "/staff/all",
      queryParameters: roleId == null
          ? null
          : {
              "role_id": roleId,
            },
    );
  }

  Future<Response> deleteStaff(int id) async {
    return await dio.delete(
      "/staff/$id",
    );
  }

  Future<Response> getStaffProfile(int id, {bool isManager = false}) {
    if (isManager) {
      return dio.get("/get/profile");
    }

    return dio.get("/staff/$id");
  }

  Future<Response> updateStaff(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await dio.patch(
      "/staff/$id/update",
      queryParameters: data,
    );
  }
}
