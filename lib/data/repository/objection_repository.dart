import 'package:dio/dio.dart';
import 'package:school_management/data/services/objection_service.dart';

import '../model/objection_model.dart';

class ObjectionRepository {
  final ObjectionService service;

  ObjectionRepository(this.service);
  Future<List<ObjectionModel>> getObjections() async {
    try {
      final response = await service.getObjections();

      final data = response.data['data'];

      if (data is! List) {
        return [];
      }

      return data
          .map(
            (item) => ObjectionModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?.toString() ?? e.message ?? e.toString(),
      );
    }
  }
  Future<String> updateObjectionStatus({
    required int id,
    required String status,
  }) async {
    try {
      final response = await service.updateObjectionStatus(
        id: id,
        status: status,
      );

      return response.data['message'] ??
          'Objection status updated successfully';
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?.toString() ?? e.message ?? e.toString(),
      );
    }
  }
}
