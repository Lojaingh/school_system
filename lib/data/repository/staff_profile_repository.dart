import 'package:dio/dio.dart';
import 'package:school_management/data/services/staff_profile_service.dart';
import '../model/staff_profile_model.dart';

class StaffProfileRepository {
  final StaffProfileService service;

  StaffProfileRepository(this.service);

  Future<List<StaffProfileModel>> getStaff({int? roleId}) async {
    try {
      final response = await service.getStaff(
        roleId: roleId,
      );

      final List data = response.data["data"];

      return data
          .map(
            (e) => StaffProfileModel.fromJson(e),
          )
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data.toString() ?? e.toString(),
      );
    }
  }

  Future<void> deleteStaff(int id) async {
    try {
      await service.deleteStaff(id);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data.toString() ?? e.toString(),
      );
    }
  }

  Future<String> updateStaff(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await service.updateStaff(
        id,
        data,
      );

      return response.data["message"];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data.toString() ?? e.toString(),
      );
    }
  }

  Future<StaffProfileModel> getStaffProfile(
    int id, {
    bool isManager = false,
  }) async {
    try {
      final response = await service.getStaffProfile(
        id,
        isManager: isManager,
      );

      return StaffProfileModel.fromProfileJson(
        response.data["data"],
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data.toString() ?? e.toString(),
      );
    }
  }
}
