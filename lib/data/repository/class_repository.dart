import '../model/class_model.dart';
import '../model/student_profile_model.dart';
import '../services/class_service.dart';

class ClassRepository {
  final ClassService classService;

  ClassRepository(this.classService);

  // ============================================================
  // GET CLASSES
  // ============================================================

  Future<List<SchoolClass>> getClasses() async {
    try {
      final response = await classService.getClasses();
      print('🔥 CLASSES RESPONSE: ${response.data}');

      if (response.statusCode == 200) {
        dynamic rawData = response.data;

        if (rawData is Map && rawData['data'] != null) {
          rawData = rawData['data'];
        }

        if (rawData is List) {
          return rawData
              .map(
                (json) => SchoolClass.fromJson(
                  Map<String, dynamic>.from(json),
                ),
              )
              .toList();
        }

        return [];
      }

      throw Exception(
        'Failed to load classes: ${response.statusCode}',
      );
    } catch (e) {
      print('❌ Error fetching classes: $e');
      rethrow;
    }
  }

  // ============================================================
  // GET CLASSES BY GRADE
  // ============================================================

  Future<List<SchoolClass>> getClassesByGrade(
    int year,
  ) async {
    try {
      final response = await classService.getClassesByGrade(year);

      if (response.statusCode == 200) {
        dynamic rawData = response.data;

        if (rawData is Map && rawData['data'] != null) {
          rawData = rawData['data'];
        }

        if (rawData is List) {
          return rawData
              .map(
                (json) => SchoolClass.fromJson(
                  Map<String, dynamic>.from(json),
                ),
              )
              .toList();
        }

        return [];
      }

      throw Exception(
        'Failed to load classes by grade: '
        '${response.statusCode}',
      );
    } catch (e) {
      print(
        '❌ Error fetching classes by grade: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // GET STUDENTS OF CLASS
  // ============================================================

  Future<List<StudentProfileModel>> getClassStudents(
    int classId,
  ) async {
    try {
      final response = await classService.getClassStudents(classId);

      if (response.statusCode == 200) {
        dynamic rawData = response.data;

        if (rawData is Map && rawData['data'] != null) {
          rawData = rawData['data'];
        }

        if (rawData is List) {
          return rawData
              .map(
                (json) => StudentProfileModel.fromJson(
                  Map<String, dynamic>.from(json),
                ),
              )
              .toList();
        }

        return [];
      }

      throw Exception(
        'Failed to load class students: '
        '${response.statusCode}',
      );
    } catch (e) {
      print(
        '❌ Error fetching class students: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // ADD CLASS
  // ============================================================

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
          return SchoolClass.fromJson(
            Map<String, dynamic>.from(
              response.data['data'],
            ),
          );
        }

        if (response.data is Map) {
          return SchoolClass.fromJson(
            Map<String, dynamic>.from(
              response.data,
            ),
          );
        }

        throw Exception(
          'Invalid response format',
        );
      }

      throw Exception(
        'Failed to add class: '
        '${response.statusCode}',
      );
    } catch (e) {
      print('❌ Error adding class: $e');
      rethrow;
    }
  }

  // ============================================================
  // DELETE CLASS
  // ============================================================

  Future<void> deleteClass(int id) async {
    try {
      final response = await classService.deleteClass(id);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to delete class: '
          '${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error deleting class: $e');
      rethrow;
    }
  }

  // ============================================================
  // DISTRIBUTE STUDENTS
  // ============================================================

  Future<void> distributeStudents(
    int capacity,
  ) async {
    try {
      final response = await classService.distributeStudents(
        capacity,
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to distribute students: '
          '${response.statusCode}',
        );
      }
    } catch (e) {
      print(
        '❌ Error distributing students: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // MOVE STUDENT
  // ============================================================

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
        throw Exception(
          'Failed to move student: '
          '${response.statusCode}',
        );
      }
    } catch (e) {
      print(
        '❌ Error moving student: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // GET SUPERVISORS
  // ============================================================

  Future<List<Map<String, dynamic>>> getSupervisors() async {
    try {
      final response = await classService.getSupervisors();

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load supervisors: '
          '${response.statusCode}',
        );
      }

      dynamic rawData = response.data;

      if (rawData is Map && rawData['data'] != null) {
        rawData = rawData['data'];
      }

      if (rawData is! List) {
        return [];
      }

      return rawData
          .map(
            (e) => Map<String, dynamic>.from(e),
          )
          .toList();
    } catch (e) {
      print(
        '❌ Error fetching supervisors: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // UPDATE CLASS SUPERVISOR
  // ============================================================

  Future<void> updateClassSupervisor({
    required int classId,
    required int? supervisorId,
  }) async {
    try {
      final response = await classService.updateClassSupervisor(
        classId: classId,
        supervisorId: supervisorId,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Failed to update supervisor: '
          '${response.statusCode}',
        );
      }
    } catch (e) {
      print(
        '❌ Error updating class supervisor: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // ASSIGN SUPERVISOR
  // ============================================================

  Future<void> assignSupervisor({
    required int classId,
    required int supervisorId,
  }) async {
    try {
      final response = await classService.assignSupervisor(
        classId: classId,
        supervisorId: supervisorId,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Failed to assign supervisor: '
          '${response.statusCode}',
        );
      }
    } catch (e) {
      print(
        '❌ Error assigning supervisor: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // GET STUDENTS BY GRADE
  // ============================================================

  Future<List<StudentProfileModel>> getStudentsByGrade(
    int year,
  ) async {
    try {
      final response = await classService.getStudentsByGrade(year);

      if (response.statusCode == 200) {
        dynamic rawData = response.data;

        if (rawData is Map && rawData['data'] != null) {
          rawData = rawData['data'];
        }

        if (rawData is List) {
          return rawData
              .map(
                (json) => StudentProfileModel.fromJson(
                  Map<String, dynamic>.from(json),
                ),
              )
              .toList();
        }

        return [];
      }

      throw Exception(
        'Failed to load students by grade: '
        '${response.statusCode}',
      );
    } catch (e) {
      print(
        '❌ Error fetching students by grade: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // GET ALL STUDENTS
  // ============================================================

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
          .map(
            (e) => e['id'] ?? e['user_id'],
          )
          .map(
            (id) {
              if (id is int) return id;
              return int.tryParse(id?.toString() ?? '');
            },
          )
          .whereType<int>()
          .toList();

      final students = <StudentProfileModel>[];

      for (final id in ids) {
        try {
          final detailResponse = await classService.getStudentById(id);

          final data = detailResponse.data;

          final studentJson =
              (data is Map && data['data'] != null) ? data['data'] : data;

          if (studentJson is! Map) {
            continue;
          }

          final student = StudentProfileModel.fromJson({
            'user_id': id,
            ...Map<String, dynamic>.from(
              studentJson,
            ),
          });

          students.add(student);
        } catch (e) {
          print(
            '⚠️ Skipped student $id '
            '(failed to fetch details): $e',
          );
        }
      }

      return students;
    } catch (e) {
      print(
        '❌ Error fetching all students: $e',
      );

      rethrow;
    }
  }
}
