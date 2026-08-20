import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_management/data/repository/external_repository.dart';

import 'external_state.dart';

class ExternalCubit extends Cubit<ExternalState> {
  final ExternalRepository repository;

  ExternalCubit(this.repository) : super(ExternalInitial());

  Future<void> getExternals() async {
    try {
      emit(ExternalLoading());

      final data = await repository.getExternals();

      emit(
        ExternalLoaded(data),
      );
    } catch (e) {
      emit(
        ExternalError(e.toString()),
      );
    }
  }

  Future<void> getExternal(int id) async {
    try {
      emit(ExternalDetailsLoading());

      final data = await repository.getExternal(id);

      emit(
        ExternalDetailsLoaded(data),
      );
    } catch (e) {
      emit(
        ExternalError(e.toString()),
      );
    }
  }

  Future<void> addExternal({
    required int schoolClassId,
    required PlatformFile file,
    String? notes,
  }) async {
    try {
      emit(ExternalAddLoading());

      final message = await repository.addExternal(
        schoolClassId: schoolClassId,
        file: file,
        notes: notes,
      );

      final data = await repository.getExternals();

      emit(
        ExternalAddSuccess(message),
      );

      emit(
        ExternalLoaded(data),
      );
    } catch (e) {
      emit(
        ExternalError(e.toString()),
      );
    }
  }

  Future<void> updateExternal({
    required int id,
    int? schoolClassId,
    PlatformFile? file,
    String? notes,
  }) async {
    try {
      emit(ExternalUpdateLoading());

      final message = await repository.updateExternal(
        id: id,
        schoolClassId: schoolClassId,
        file: file,
        notes: notes,
      );

      final data = await repository.getExternals();

      emit(
        ExternalUpdateSuccess(
          message: message,
          externals: data,
        ),
      );
    } catch (e) {
      emit(
        ExternalError(e.toString()),
      );
    }
  }

  Future<void> deleteExternal(int id) async {
    try {
      emit(ExternalDeleteLoading());

      final message = await repository.deleteExternal(id);

      final data = await repository.getExternals();

      emit(
        ExternalDeleteSuccess(
          message: message,
          externals: data,
        ),
      );
    } catch (e) {
      emit(
        ExternalError(e.toString()),
      );
    }
  }

  // =========================
  // TEACHER
  // =========================

  Future<void> getTeacherClasses() async {
    try {
      emit(TeacherClassesLoading());

      final data = await repository.getTeacherClasses();

      emit(
        TeacherClassesLoaded(data),
      );
    } catch (e) {
      emit(
        ExternalError(e.toString()),
      );
    }
  }

  // =========================
  // MANAGER
  // =========================

  Future<void> getAllClasses() async {
    try {
      emit(AllClassesLoading());

      final data = await repository.getAllClasses();

      emit(
        AllClassesLoaded(data),
      );
    } catch (e) {
      emit(
        ExternalError(e.toString()),
      );
    }
  }
}
