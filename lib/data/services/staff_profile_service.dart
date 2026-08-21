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

  Future<Response> getStaffProfile(
    int id, {
    bool isManager = false,
  }) async {
    if (isManager) {
      return await dio.get("/get/profile");
    }

    return await dio.get("/staff/$id");
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

  Future<Response> resetPassword(
    int id,
    String newPassword,
    String confirmPassword,
  ) async {
    final data = {
      "new_password": newPassword,
      "new_password_confirmation": confirmPassword,
    };

    print("🔐 RESET PASSWORD");
    print("USER ID: $id");
    print("BODY: $data");

    return await dio.patch(
      "/update/$id/password",
      data: data,
    );
  }
}
