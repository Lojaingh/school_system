import 'package:dio/dio.dart';
import '../model/subject_model.dart';
import '../network/dio_client.dart';

class SubjectService {
  final Dio dio = DioClient.dio;

  Future<Response> addSubject(SubjectModel subject) async {
    return await dio.post(
      '/subjects',
      data: subject.toJson(),
    );
  }

  Future<Response> getSubjects() async {
    return await dio.get(
      '/subjects',
    );
  }

  Future<Response> getSubject(int id) async {
    return await dio.get(
      '/subjects/$id',
    );
  }

  Future<Response> updateSubject(
    int id,
    SubjectModel subject,
  ) async {
    return await dio.put(
      '/subjects/$id',
      data: subject.toJson(),
    );
  }

  Future<Response> deleteSubject(int id) async {
    return await dio.delete(
      '/subjects/$id',
    );
  }
}
