import 'package:school_management/data/network/dio_client.dart';

class AssignmentService {
  Future<List<dynamic>> getAssignments() async {
    final response = await DioClient.dio.get('/assignments');

    return response.data['data'];
  }
}
