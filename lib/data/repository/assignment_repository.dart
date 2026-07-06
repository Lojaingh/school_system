import 'package:school_management/data/model/assignment_model.dart';
import 'package:school_management/data/services/assignment_service.dart';

class AssignmentRepository {
  final AssignmentService _service = AssignmentService();

  Future<List<Assignment>> getAssignments() async {
    final response = await _service.getAssignments();

    return response
        .map<Assignment>((json) => Assignment.fromJson(json))
        .toList();
  }
}
