import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/cubit/staff/staff_profile_state.dart';
import 'package:school_management/data/repository/staff_profile_repository.dart';

class StaffProfileCubit extends Cubit<StaffProfileState> {
  final StaffProfileRepository repository;

  StaffProfileCubit(this.repository) : super(StaffInitial());

  Future<void> getStaff({int? roleId}) async {
    try {
      emit(StaffLoading());

      final data = await repository.getStaff(
        roleId: roleId,
      );

      emit(
        StaffLoaded(data),
      );
    } catch (e) {
      emit(
        StaffError(
          e.toString(),
        ),
      );
    }
  }

  Future<void> deleteStaff(int id) async {
    try {
      await repository.deleteStaff(id);

      await getStaff();
    } catch (e) {
      emit(
        StaffError(
          e.toString(),
        ),
      );
    }
  }

  Future<void> updateStaff(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      await repository.updateStaff(
        id,
        data,
      );
    } catch (e) {
      emit(
        StaffError(
          e.toString(),
        ),
      );

      rethrow;
    }
  }

  Future<void> getStaffProfile(
    int id, {
    bool isManager = false,
  }) async {
    try {
      emit(StaffLoading());

      final data = await repository.getStaffProfile(
        id,
        isManager: isManager,
      );

      emit(
        StaffProfileLoaded(data),
      );
    } catch (e) {
      emit(
        StaffError(
          e.toString(),
        ),
      );
    }
  }

  // Reset Password
  Future<String?> resetPassword(
    int id,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      final message = await repository.resetPassword(
        id,
        newPassword,
        confirmPassword,
      );

      return message;
    } catch (e) {
      print("RESET PASSWORD ERROR: $e");

      emit(
        StaffError(
          e.toString(),
        ),
      );

      return null;
    }
  }
}
