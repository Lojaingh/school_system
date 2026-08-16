// lib/data/repository/assignment_repository.dart

import 'package:dio/dio.dart';
import 'package:school_management/data/model/assignment_model.dart';
import '../network/dio_client.dart';

class AssignmentRepository {
  AssignmentRepository();

  Future<List<Assignment>> getAssignments() async {
    try {
      final response = await DioClient.dio.get('/assignments');

      print('📥 Assignments response status: ${response.statusCode}');
      print('📥 Assignments response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        List dataList = [];

        // ✅ معالجة مختلف أشكال الـ Response
        if (responseData == null) {
          return [];
        }

        // حالة 1: response.data['data'] هي مصفوفة مباشرة
        if (responseData['data'] is List) {
          dataList = responseData['data'] as List;
        }
        // حالة 2: response.data['data'] هي Map فيها 'data' مصفوفة (Pagination)
        else if (responseData['data'] is Map &&
            responseData['data']['data'] is List) {
          dataList = responseData['data']['data'] as List;
        }
        // حالة 3: response.data نفسها مصفوفة
        else if (responseData is List) {
          dataList = responseData;
        }
        // حالة 4: response.data['data'] فيها 'data' مصفوفة
        else if (responseData['data'] != null && responseData['data'] is List) {
          dataList = responseData['data'] as List;
        } else {
          dataList = [];
        }

        print('📥 Found ${dataList.length} assignments');

        return dataList.map((json) => Assignment.fromJson(json)).toList();
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

  // ── تحديث مهمة ──
  Future<Assignment> updateAssignment({
    required int id,
    String? title,
    String? body,
    String? dueDate,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (title != null && title.trim().isNotEmpty)
        data['title'] = title.trim();
      if (body != null && body.trim().isNotEmpty) data['body'] = body.trim();
      if (dueDate != null && dueDate.trim().isNotEmpty)
        data['due_date'] = dueDate.trim();

      if (data.isEmpty) {
        throw Exception('No data to update');
      }

      print('📤 Updating assignment $id with: $data');

      final response = await DioClient.dio.put(
        '/assignments/$id',
        data: data,
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final assignmentData = response.data['data'];
        return Assignment.fromJson(assignmentData);
      } else {
        throw Exception('Failed to update assignment: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioError updating assignment: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('❌ Error updating assignment: $e');
      rethrow;
    }
  }

  // ── حذف مهمة ──
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
