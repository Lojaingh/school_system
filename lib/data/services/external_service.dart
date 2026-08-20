import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

import '../network/dio_client.dart';

class ExternalService {
  final Dio dio = DioClient.dio;

  Future<Response> getExternals() async {
    return await dio.get("/externals");
  }

  Future<Response> getExternal(int id) async {
    return await dio.get("/externals/$id");
  }

  Future<Response> addExternal({
    required int schoolClassId,
    required PlatformFile file,
    String? notes,
  }) async {
    if (file.bytes == null) {
      throw Exception("File data is not available");
    }

    final multipartFile = MultipartFile.fromBytes(
      file.bytes!,
      filename: file.name,
    );

    final formData = FormData.fromMap({
      "school_class_id": schoolClassId,
      "path": multipartFile,
      if (notes != null && notes.isNotEmpty) "notes": notes,
    });

    return await dio.post(
      "/externals",
      data: formData,
    );
  }

  Future<Response> updateExternal({
    required int id,
    int? schoolClassId,
    PlatformFile? file,
    String? notes,
  }) async {
    final Map<String, dynamic> data = {
      "_method": "PUT",
    };

    if (schoolClassId != null) {
      data["school_class_id"] = schoolClassId;
    }

    if (notes != null) {
      data["notes"] = notes;
    }

    if (file != null && file.bytes != null) {
      data["path"] = MultipartFile.fromBytes(
        file.bytes!,
        filename: file.name,
      );
    }

    final formData = FormData.fromMap(data);

    return await dio.post(
      "/externals/$id",
      data: formData,
    );
  }

  Future<Response> deleteExternal(int id) async {
    return await dio.delete(
      "/externals/$id",
    );
  }

  // Teacher
  Future<Response> getTeacherClasses() async {
    return await dio.get(
      "/teacher/classes",
    );
  }

  // Manager
  Future<Response> getAllClasses() async {
    return await dio.get(
      "/class/all",
    );
  }
}
