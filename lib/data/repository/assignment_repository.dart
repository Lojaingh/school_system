import 'package:dio/dio.dart';
import 'package:school_management/data/model/assignment_model.dart';
import '../network/dio_client.dart';

class AssignmentRepository {
  AssignmentRepository();

  // ============================================================
  // GET ASSIGNMENTS
  // ============================================================

  Future<List<Assignment>> getAssignments() async {
    try {
      final response = await DioClient.dio.get('/assignments');

      print(
        '📥 Assignments response status: ${response.statusCode}',
      );

      print(
        '📥 Assignments response data: ${response.data}',
      );

      final responseData = response.data;

      if (responseData == null) {
        return [];
      }

      List<dynamic> dataList = [];

      if (responseData is Map && responseData['data'] is List) {
        dataList = responseData['data'];
      } else if (responseData is List) {
        dataList = responseData;
      } else if (responseData is Map &&
          responseData['data'] is Map &&
          responseData['data']['data'] is List) {
        dataList = responseData['data']['data'];
      }

      print(
        '📥 Found ${dataList.length} assignments',
      );

      return dataList
          .whereType<Map>()
          .map(
            (json) => Assignment.fromJson(
              Map<String, dynamic>.from(json),
            ),
          )
          .toList();
    } catch (e) {
      print(
        '❌ Error fetching assignments: $e',
      );
      rethrow;
    }
  }

  // ============================================================
  // GET CLASSES
  // ============================================================

  Future<List<Map<String, dynamic>>> getClasses({
    required String role,
  }) async {
    try {
      final normalizedRole = role.trim().toLowerCase();

      final endpoint =
          normalizedRole == 'teacher' ? '/teacher/classes' : '/class/all';

      print('🔵 User role: $normalizedRole');
      print('🔵 Fetching classes from: $endpoint');

      final response = await DioClient.dio.get(endpoint);

      print(
        '📥 Classes response status: ${response.statusCode}',
      );

      print(
        '📥 Classes response data: ${response.data}',
      );

      final responseData = response.data;

      List<dynamic> data = [];

      if (responseData is List) {
        data = responseData;
      } else if (responseData is Map && responseData['data'] is List) {
        data = responseData['data'];
      } else if (responseData is Map &&
          responseData['data'] is Map &&
          responseData['data']['data'] is List) {
        data = responseData['data']['data'];
      }

      print(
        '🟢 Classes extracted: ${data.length}',
      );

      return data
          .whereType<Map>()
          .map(
            (item) => Map<String, dynamic>.from(item),
          )
          .toList();
    } on DioException catch (e) {
      print(
        '❌ Error loading classes: ${e.response?.data}',
      );

      rethrow;
    } catch (e) {
      print(
        '❌ Error loading classes: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // GET ASSIGNMENT BY ID
  // ============================================================

  Future<Assignment> getAssignmentById(
    int id,
  ) async {
    try {
      final response = await DioClient.dio.get(
        '/assignments/$id',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        final data = responseData is Map && responseData['data'] != null
            ? responseData['data']
            : responseData;

        return Assignment.fromJson(
          Map<String, dynamic>.from(data),
        );
      }

      throw Exception(
        'Failed to load assignment: ${response.statusCode}',
      );
    } catch (e) {
      print(
        '❌ Error fetching assignment: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // CREATE ASSIGNMENT
  // ============================================================

  Future<Assignment> createAssignment({
    required String title,
    required String body,
    required String dueDate,
    required int subjectId,
    required int schoolClassId,
    String? filePath,
  }) async {
    try {
      print('📤 Creating assignment');
      print('   school_class_id: $schoolClassId');
      print('   subject_id: $subjectId');
      print('   title: $title');
      print('   due_date: $dueDate');

      if (filePath != null && filePath.isNotEmpty) {
        final formData = FormData.fromMap({
          'school_class_id': schoolClassId,
          'subject_id': subjectId,
          'title': title,
          'body': body,
          'due_date': dueDate,
          'file_path': await MultipartFile.fromFile(
            filePath,
          ),
        });

        final response = await DioClient.dio.post(
          '/assignments',
          data: formData,
          options: Options(
            contentType: 'multipart/form-data',
          ),
        );

        print(
          '📥 Create response: ${response.data}',
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseData = response.data;

          final assignmentData =
              responseData is Map && responseData['data'] != null
                  ? responseData['data']
                  : responseData;

          return Assignment.fromJson(
            Map<String, dynamic>.from(
              assignmentData,
            ),
          );
        }

        throw Exception(
          'Failed to create assignment: ${response.statusCode}',
        );
      }

      final response = await DioClient.dio.post(
        '/assignments',
        data: {
          'school_class_id': schoolClassId,
          'subject_id': subjectId,
          'title': title,
          'body': body,
          'due_date': dueDate,
        },
      );

      print(
        '📥 Create response: ${response.data}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        final assignmentData =
            responseData is Map && responseData['data'] != null
                ? responseData['data']
                : responseData;

        return Assignment.fromJson(
          Map<String, dynamic>.from(
            assignmentData,
          ),
        );
      }

      throw Exception(
        'Failed to create assignment: ${response.statusCode}',
      );
    } on DioException catch (e) {
      print(
        '❌ Create Assignment Dio Error: ${e.response?.data}',
      );

      rethrow;
    } catch (e) {
      print(
        '❌ Error creating assignment: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // UPDATE ASSIGNMENT
  // ============================================================

  Future<Assignment> updateAssignment({
    required int id,
    int? subjectId,
    String? title,
    String? body,
    String? dueDate,
  }) async {
    try {
      final Map<String, dynamic> data = {};

      if (subjectId != null) {
        data['subject_id'] = subjectId;
      }

      if (title != null && title.trim().isNotEmpty) {
        data['title'] = title.trim();
      }

      if (body != null && body.trim().isNotEmpty) {
        data['body'] = body.trim();
      }

      if (dueDate != null && dueDate.trim().isNotEmpty) {
        data['due_date'] = dueDate.trim();
      }

      if (data.isEmpty) {
        throw Exception(
          'No data to update',
        );
      }

      print(
        '📤 Updating assignment $id',
      );

      print(
        '📤 Data: $data',
      );

      final response = await DioClient.dio.put(
        '/assignments/$id',
        data: data,
      );

      print(
        '📥 Update status: ${response.statusCode}',
      );

      print(
        '📥 Update data: ${response.data}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        final assignmentData =
            responseData is Map && responseData['data'] != null
                ? responseData['data']
                : responseData;

        return Assignment.fromJson(
          Map<String, dynamic>.from(
            assignmentData,
          ),
        );
      }

      throw Exception(
        'Failed to update assignment: ${response.statusCode}',
      );
    } on DioException catch (e) {
      print(
        '❌ Update Assignment Dio Error: ${e.response?.data}',
      );

      rethrow;
    } catch (e) {
      print(
        '❌ Error updating assignment: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // DELETE ASSIGNMENT
  // ============================================================

  Future<void> deleteAssignment(
    int id,
  ) async {
    try {
      final response = await DioClient.dio.delete(
        '/assignments/$id',
      );

      print(
        '📥 Delete status: ${response.statusCode}',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to delete assignment: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print(
        '❌ Delete Assignment Error: ${e.response?.data}',
      );

      rethrow;
    } catch (e) {
      print(
        '❌ Error deleting assignment: $e',
      );

      rethrow;
    }
  }
}
