// lib/cubit/assignment/assignment_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_management/cubit/assignment/assignment_state.dart';
import 'package:school_management/data/repository/assignment_repository.dart';

import '../../data/model/assignment_model.dart';

class AssignmentCubit extends Cubit<AssignmentState> {
  final AssignmentRepository repository;

  AssignmentCubit(this.repository) : super(AssignmentInitial());

  // ============================================================
  // LOAD ASSIGNMENTS
  // ============================================================

  Future<void> loadAssignments() async {
    try {
      emit(AssignmentLoading());

      final assignments = await repository.getAssignments();

      final sortedAssignments = List<Assignment>.from(assignments)
        ..sort(
          (a, b) => a.dueDate.compareTo(
            b.dueDate,
          ),
        );

      final upcoming = sortedAssignments
          .where(
            (assignment) => !assignment.isOverdue,
          )
          .take(5)
          .toList();

      emit(
        AssignmentLoaded(
          assignments: sortedAssignments,
          upcomingAssignments: upcoming,
        ),
      );
    } catch (e) {
      emit(
        AssignmentError(
          e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  void refreshAssignments() {
    loadAssignments();
  }

  // ============================================================
  // ADD ASSIGNMENT
  // ============================================================

  Future<void> addAssignment({
    required String title,
    required String body,
    required String dueDate,

    // رقم المادة
    required int subjectId,
    String? filePath,
  }) async {
    try {
      emit(AssignmentLoading());

      await repository.createAssignment(
        title: title,
        body: body,
        dueDate: dueDate,
        subjectId: subjectId,
        filePath: filePath,
      );

      await loadAssignments();
    } catch (e) {
      print(
        '❌ Add Assignment Error: $e',
      );

      emit(
        AssignmentError(
          e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // UPDATE ASSIGNMENT
  // ============================================================

  Future<void> updateAssignment({
    required int id,

    // رقم المادة
    int? subjectId,
    String? title,
    String? body,
    String? dueDate,
  }) async {
    try {
      emit(AssignmentLoading());

      print(
        '📤 Cubit - Updating assignment',
      );

      print('   id: $id');
      print('   subjectId: $subjectId');
      print('   title: $title');
      print('   body: $body');
      print('   dueDate: $dueDate');

      await repository.updateAssignment(
        id: id,
        subjectId: subjectId,
        title: title,
        body: body,
        dueDate: dueDate,
      );

      await loadAssignments();
    } catch (e) {
      print(
        '❌ Update error: $e',
      );

      emit(
        AssignmentError(
          e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // DELETE ASSIGNMENT
  // ============================================================

  Future<void> deleteAssignment(
    int id,
  ) async {
    try {
      emit(AssignmentLoading());

      await repository.deleteAssignment(
        id,
      );

      await loadAssignments();
    } catch (e) {
      emit(
        AssignmentError(
          e.toString(),
        ),
      );
    }
  }
}
