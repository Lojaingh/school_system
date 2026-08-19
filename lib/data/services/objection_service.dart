import 'package:dio/dio.dart';
import 'package:school_management/data/network/dio_client.dart';

class ObjectionService {
  Future<Response> getObjections() async {
    return await DioClient.dio.get(
      '/objections',
    );
  }
  Future<Response> updateObjectionStatus({
    required int id,
    required String status,
  }) async {
    return await DioClient.dio.put(
      '/objections/$id',
      data: {
        'status': status,
      },
    );
  }
}
