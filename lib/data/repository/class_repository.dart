import '../model/class_model.dart';
import '../model/student_profile_model.dart';
import '../services/class_service.dart';

class ClassRepository {
  final ClassService classService;

  ClassRepository(this.classService);

  // ── جلب جميع الصفوف ──
  Future<List<SchoolClass>> getClasses() async {
    try {
      final response = await classService.getClasses();

      if (response.statusCode == 200) {
        if (response.data is List) {
          final data = response.data as List;
          return data.map((json) => SchoolClass.fromJson(json)).toList();
        } else if (response.data is Map && response.data['data'] != null) {
          final data = response.data['data'] as List? ?? [];
          return data.map((json) => SchoolClass.fromJson(json)).toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load classes: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching classes: $e');
      rethrow;
    }
  }

  // ── جلب الصفوف حسب السنة ──
  Future<List<SchoolClass>> getClassesByGrade(int year) async {
    try {
      final response = await classService.getClassesByGrade(year);

      if (response.statusCode == 200) {
        if (response.data is List) {
          final data = response.data as List;
          return data.map((json) => SchoolClass.fromJson(json)).toList();
        } else if (response.data is Map && response.data['data'] != null) {
          final data = response.data['data'] as List? ?? [];
          return data.map((json) => SchoolClass.fromJson(json)).toList();
        } else {
          return [];
        }
      } else {
        throw Exception(
            'Failed to load classes by grade: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching classes by grade: $e');
      rethrow;
    }
  }

  // ── ✅ جلب طلاب شعبة معينة (API جديد) ──
  Future<List<StudentProfileModel>> getClassStudents(int classId) async {
    try {
      final response = await classService.getClassStudents(classId);

      if (response.statusCode == 200) {
        final data = response.data['data'] as List? ?? [];
        return data.map((json) => StudentProfileModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load class students: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching class students: $e');
      rethrow;
    }
  }

  // ── إضافة صف جديد ──
  Future<SchoolClass> addClass({
    required int year,
    required int number,
    int? supervisorId,
  }) async {
    try {
      final response = await classService.addClass(
        year: year,
        number: number,
        supervisorId: supervisorId,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map && response.data['data'] != null) {
          final data = response.data['data'];
          return SchoolClass.fromJson(data);
        } else if (response.data is Map) {
          return SchoolClass.fromJson(response.data);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to add class: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error adding class: $e');
      rethrow;
    }
  }

  // ── حذف صف ──
  Future<void> deleteClass(int id) async {
    try {
      final response = await classService.deleteClass(id);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete class: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error deleting class: $e');
      rethrow;
    }
  }

  // ── توزيع الطلاب ──
  Future<void> distributeStudents(int capacity) async {
    try {
      final response = await classService.distributeStudents(capacity);
      if (response.statusCode != 200) {
        throw Exception(
            'Failed to distribute students: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error distributing students: $e');
      rethrow;
    }
  }

  // ── نقل طالب ──
  Future<void> moveStudent({
    required int userId,
    required int classId,
  }) async {
    try {
      final response = await classService.moveStudent(
        userId: userId,
        classId: classId,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to move student: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error moving student: $e');
      rethrow;
    }
  }

  // ── جلب الطلاب حسب السنة ──
  Future<List<StudentProfileModel>> getStudentsByGrade(int year) async {
    try {
      final response = await classService.getStudentsByGrade(year);

      if (response.statusCode == 200) {
        final data = response.data['data'] as List? ?? [];
        return data.map((json) => StudentProfileModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load students by grade: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching students by grade: $e');
      rethrow;
    }
  }

  // ── جلب كل الطلاب (للحالات النادرة) ──
  Future<List<StudentProfileModel>> getAllStudents() async {
    try {
      final basicResponse = await classService.getAllStudents();

      List basicList;
      if (basicResponse.data is Map && basicResponse.data['data'] != null) {
        basicList = basicResponse.data['data'] as List? ?? [];
      } else if (basicResponse.data is List) {
        basicList = basicResponse.data as List;
      } else {
        basicList = [];
      }

      final ids = basicList
          .map((e) => e['id'] ?? e['user_id'])
          .whereType<int>()
          .toList();

      final students = <StudentProfileModel>[];

      for (final id in ids) {
        try {
          final detailResponse = await classService.getStudentById(id);
          final data = detailResponse.data;
          final studentJson =
              (data is Map && data['data'] != null) ? data['data'] : data;
          final student = StudentProfileModel.fromJson({
            'user_id': id,
            ...Map<String, dynamic>.from(studentJson as Map),
          });
          students.add(student);
        } catch (e) {
          print('⚠️ Skipped student $id (failed to fetch details): $e');
        }
      }

      return students;
    } catch (e) {
      print('❌ Error fetching all students: $e');
      rethrow;
    }
  }
}
