// lib/data/repository/assignment_repository.dart

import 'package:dio/dio.dart';
import 'package:school_management/data/model/assignment_model.dart';
import '../network/dio_client.dart';

class AssignmentRepository {
  AssignmentRepository();

  // ============================================================
  // GET ALL ASSIGNMENTS
  // ============================================================

  Future<List<Assignment>> getAssignments() async {
    try {
      final response = await DioClient.dio.get('/assignments');

      print(
        '📥 Assignments response status: '
        '${response.statusCode}',
      );

      print(
        '📥 Assignments response data: '
        '${response.data}',
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Failed to load assignments: '
          '${response.statusCode}',
        );
      }

      final responseData = response.data;

      if (responseData == null) {
        return [];
      }

      List<dynamic> dataList = [];

      // ----------------------------------------
      // data = [...]
      // ----------------------------------------

      if (responseData is Map && responseData['data'] is List) {
        dataList = responseData['data'];
      }

      // ----------------------------------------
      // response = [...]
      // ----------------------------------------

      else if (responseData is List) {
        dataList = responseData;
      }

      // ----------------------------------------
      // data = { data: [...] }
      // Pagination
      // ----------------------------------------

      else if (responseData is Map &&
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
        'Failed to load assignment: '
        '${response.statusCode}',
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

    // رقم المادة فقط
    required int subjectId,
    String? filePath,
  }) async {
    try {
      print('📤 Creating assignment');
      print('   subject_id: $subjectId');
      print('   title: $title');
      print('   due_date: $dueDate');

      // ========================================================
      // WITH FILE
      // ========================================================

      if (filePath != null && filePath.isNotEmpty) {
        final formData = FormData.fromMap({
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
          '📥 Create response: '
          '${response.data}',
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
          'Failed to create assignment: '
          '${response.statusCode}',
        );
      }

      // ========================================================
      // WITHOUT FILE
      // ========================================================

      final response = await DioClient.dio.post(
        '/assignments',
        data: {
          'subject_id': subjectId,
          'title': title,
          'body': body,
          'due_date': dueDate,
        },
      );

      print(
        '📥 Create response: '
        '${response.data}',
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
        'Failed to create assignment: '
        '${response.statusCode}',
      );
    } on DioException catch (e) {
      print(
        '❌ Create Assignment Dio Error: '
        '${e.response?.data}',
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

    // المادة اختيارية بالتعديل
    int? subjectId,
    String? title,
    String? body,
    String? dueDate,
  }) async {
    try {
      final Map<String, dynamic> data = {};

      // رقم المادة
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
        '📥 Update status: '
        '${response.statusCode}',
      );

      print(
        '📥 Update data: '
        '${response.data}',
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
        'Failed to update assignment: '
        '${response.statusCode}',
      );
    } on DioException catch (e) {
      print(
        '❌ Update Assignment Dio Error: '
        '${e.response?.data}',
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
        '📥 Delete status: '
        '${response.statusCode}',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to delete assignment: '
          '${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print(
        '❌ Delete Assignment Error: '
        '${e.response?.data}',
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
