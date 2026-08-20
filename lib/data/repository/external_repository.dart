import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

import '../model/external_model.dart';
import '../model/school_class_model.dart';
import '../services/external_service.dart';

class ExternalRepository {
  final ExternalService service;

  ExternalRepository(this.service);

  // =========================
  // EXTERNALS
  // =========================

  Future<List<ExternalModel>> getExternals() async {
    try {
      final response = await service.getExternals();

      print("🟣 EXTERNALS RESPONSE:");
      print(response.data);

      final data = response.data['data'];

      if (data is! List) {
        print("🔴 EXTERNAL DATA IS NOT LIST");
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
    } catch (e) {
      throw Exception(e.toString());
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
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // =========================
  // ADD
  // =========================

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

      return response.data['message']?.toString() ?? 'Uploaded successfully';
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?.toString() ?? e.message ?? e.toString(),
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // =========================
  // UPDATE
  // =========================

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

      return response.data['message']?.toString() ??
          'External updated successfully';
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?.toString() ?? e.message ?? e.toString(),
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // =========================
  // DELETE
  // =========================

  Future<String> deleteExternal(int id) async {
    try {
      final response = await service.deleteExternal(id);

      return response.data['message']?.toString() ??
          'External deleted successfully';
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?.toString() ?? e.message ?? e.toString(),
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // =========================
  // TEACHER CLASSES
  // =========================

  Future<List<SchoolClassModel>> getTeacherClasses() async {
    try {
      print("🟣 REPOSITORY: getTeacherClasses()");

      final response = await service.getTeacherClasses();

      print("🟢 TEACHER CLASSES RESPONSE:");
      print(response.data);

      dynamic rawData = response.data;

      // إذا الـ API رجع {data: [...]}
      if (rawData is Map<String, dynamic>) {
        rawData = rawData['data'];
      }

      if (rawData is! List) {
        print("🔴 TEACHER CLASS RESPONSE IS NOT LIST");
        return [];
      }

      final classes = rawData
          .map(
            (item) => SchoolClassModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

      print("🟢 TEACHER CLASSES PARSED: ${classes.length}");

      return classes;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?.toString() ?? e.message ?? e.toString(),
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // =========================
  // MANAGER - ALL CLASSES
  // =========================

  Future<List<SchoolClassModel>> getAllClasses() async {
    try {
      print("🟣 REPOSITORY: getAllClasses()");

      final response = await service.getAllClasses();

      print("🟢 ALL CLASSES RESPONSE:");
      print(response.data);

      dynamic rawData = response.data;

      // مهم جداً:
      // /class/all عندك يرجع List مباشرة
      //
      // [
      //   {id: 17, ...},
      //   {id: 18, ...}
      // ]
      //
      // وليس:
      //
      // {data: [...]}

      if (rawData is Map<String, dynamic>) {
        rawData = rawData['data'];
      }

      if (rawData is! List) {
        print("🔴 CLASS RESPONSE IS NOT LIST");
        print("🔴 TYPE: ${rawData.runtimeType}");
        return [];
      }

      print("🟢 RAW CLASSES COUNT: ${rawData.length}");

      final List<SchoolClassModel> classes = [];

      for (final item in rawData) {
        try {
          if (item is! Map) {
            print("🔴 CLASS ITEM IS NOT MAP: $item");
            continue;
          }

          final map = Map<String, dynamic>.from(item);

          print("🟡 PARSING CLASS: $map");

          final schoolClass = SchoolClassModel.fromJson(map);

          classes.add(schoolClass);

          print(
            "🟢 CLASS PARSED → "
            "id=${schoolClass.id}, "
            "label=${schoolClass.label}, "
            "year=${schoolClass.year}, "
            "number=${schoolClass.number}",
          );
        } catch (e) {
          print("🔴 CLASS PARSE ERROR: $e");
        }
      }

      print(
        "🟢 ALL CLASSES PARSED: ${classes.length}",
      );

      return classes;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?.toString() ?? e.message ?? e.toString(),
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
