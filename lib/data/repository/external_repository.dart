import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

import '../model/external_model.dart';
import '../model/school_class_model.dart';
import '../services/external_service.dart';

class ExternalRepository {
  final ExternalService service;

  ExternalRepository(this.service);
  Future<List<ExternalModel>> getExternals() async {
    try {
      final response = await service.getExternals();

      print("🟣 EXTERNALS RESPONSE:");
      print(response.data);

      final data = response.data['data'];

      if (data is! List) {
        return [];
      }

      return data
          .map(
            (item) => ExternalModel.fromJson(
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

  Future<ExternalModel> getExternal(int id) async {
    try {
      final response = await service.getExternal(id);

      final data = response.data['data'];

      if (data == null) {
        throw Exception('External not found');
      }

      return ExternalModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?.toString() ?? e.message ?? e.toString(),
      );
    }
  }
  Future<String> addExternal({
    required int schoolClassId,
    required PlatformFile file,
    String? notes,
  }) async {
    try {
      final response = await service.addExternal(
        schoolClassId: schoolClassId,
        file: file,
        notes: notes,
      );

      return response.data['message'] ?? 'Uploaded successfully';
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?.toString() ?? e.message ?? e.toString(),
      );
    }
  }

  Future<String> updateExternal({
    required int id,
    int? schoolClassId,
    PlatformFile? file,
    String? notes,
  }) async {
    try {
      final response = await service.updateExternal(
        id: id,
        schoolClassId: schoolClassId,
        file: file,
        notes: notes,
      );

      return response.data['message'] ?? 'External updated successfully';
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?.toString() ?? e.message ?? e.toString(),
      );
    }
  }

  Future<String> deleteExternal(int id) async {
    try {
      final response = await service.deleteExternal(id);

      return response.data['message'] ?? 'External deleted successfully';
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?.toString() ?? e.message ?? e.toString(),
      );
    }
  }

  Future<List<SchoolClassModel>> getTeacherClasses() async {
    try {
      final response = await service.getTeacherClasses();

      final rawData = response.data['data'];

      if (rawData is! List) {
        return [];
      }

      return rawData
          .map(
            (item) => SchoolClassModel.fromJson(
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

  Future<List<SchoolClassModel>> getGradeClasses(int year) async {
    try {
      final response = await service.getGradeClasses(year);

      final rawData = response.data['data'] ?? response.data;

      if (rawData is! List) {
        return [];
      }

      return rawData
          .map(
            (item) => SchoolClassModel.fromJson(
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
}
