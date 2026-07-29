// lib/repository/assignment_repository.dart
// lib/data/repository/assignment_repository.dart

import 'package:dio/dio.dart';
import 'package:school_management/data/model/assignment_model.dart';
import '../network/dio_client.dart';

class AssignmentRepository {
  AssignmentRepository();

  // ── جلب جميع المهام ──
  Future<List<Assignment>> getAssignments() async {
    try {
      final response = await DioClient.dio.get('/assignments');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] as List? ?? [];
        return data.map((json) => Assignment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load assignments: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching assignments: $e');
      rethrow;
    }
  }

  // ── جلب مهمة محددة ──
  Future<Assignment> getAssignmentById(int id) async {
    try {
      final response = await DioClient.dio.get('/assignments/$id');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        return Assignment.fromJson(data);
      } else {
        throw Exception('Failed to load assignment: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching assignment: $e');
      rethrow;
    }
  }

  // ── إضافة مهمة جديدة ──
  Future<Assignment> createAssignment({
    required String title,
    required String body,
    required String dueDate,
    required int subjectId,
    String? filePath,
  }) async {
    try {
      // إذا كان هناك ملف، نستخدم FormData
      if (filePath != null && filePath.isNotEmpty) {
        final formData = FormData.fromMap({
          'title': title,
          'body': body,
          'due_date': dueDate,
          'subject_id': subjectId,
          'file_path': await MultipartFile.fromFile(filePath),
        });

        final response = await DioClient.dio.post(
          '/assignments',
          data: formData,
          options: Options(
            headers: {
              'Content-Type': 'multipart/form-data',
            },
          ),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final assignmentData = response.data['data'];
          return Assignment.fromJson(assignmentData);
        } else {
          throw Exception(
              'Failed to create assignment: ${response.statusCode}');
        }
      } else {
        // بدون ملف (JSON)
        final response = await DioClient.dio.post(
          '/assignments',
          data: {
            'title': title,
            'body': body,
            'due_date': dueDate,
            'subject_id': subjectId,
          },
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          final assignmentData = response.data['data'];
          return Assignment.fromJson(assignmentData);
        } else {
          throw Exception(
              'Failed to create assignment: ${response.statusCode}');
        }
      }
    } on DioException catch (e) {
      print('❌ Error creating assignment: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('❌ Error creating assignment: $e');
      rethrow;
    }
  }

  // ── ✅ تحديث مهمة (معدل) ──
  Future<Assignment> updateAssignment({
    required int id,
    String? title,
    String? body,
    String? dueDate,
  }) async {
    try {
      final response = await DioClient.dio.put(
        '/assignments/$id',
        data: {
          if (title != null) "title": title,
          if (body != null) "body": body,
          if (dueDate != null) "due_date": dueDate,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final assignmentData = response.data['data'];
        return Assignment.fromJson(assignmentData);
      } else {
        throw Exception('Failed to update assignment: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Error updating assignment: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('❌ Error updating assignment: $e');
      rethrow;
    }
  }

  // ── ✅ حذف مهمة (معدل) ──
  Future<void> deleteAssignment(int id) async {
    try {
      final response = await DioClient.dio.delete('/assignments/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete assignment: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Error deleting assignment: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('❌ Error deleting assignment: $e');
      rethrow;
    }
  }
}
