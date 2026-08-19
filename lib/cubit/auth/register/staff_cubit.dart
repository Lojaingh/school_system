import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/data/model/staff_model.dart';
import 'package:school_management/data/repository/staff_repository.dart';

import 'staff_state.dart';

class StaffCubit extends Cubit<StaffRegisterState> {
  final StaffRepository repository;

  StaffCubit(this.repository) : super(StaffRegisterInitial());

  // تسجيل موظف عادي
  Future<void> registerStaff(StaffModel staff) async {
    try {
      print('STAFF REGISTER START');

      emit(StaffRegisterLoading());

      final message = await repository.registerStaff(staff);

      print('STAFF REGISTER SUCCESS');
      print(message);

      emit(StaffRegisterSuccess(message));
    } catch (e) {
      print('STAFF REGISTER ERROR');
      print(e);

      emit(
        StaffRegisterError(e.toString()),
      );
    }
  }

  // تسجيل أستاذ
  Future<void> registerTeacher(StaffModel staff) async {
    try {
      print('TEACHER REGISTER START');

      emit(StaffRegisterLoading());

      final credentials = await repository.registerTeacher(staff);

      print('TEACHER REGISTER SUCCESS');
      print('USERNAME: ${credentials['username']}');
      print('PASSWORD: ${credentials['password']}');

      emit(
        TeacherRegisterSuccess(
          username: credentials['username']!,
          password: credentials['password']!,
        ),
      );
    } catch (e) {
      print('TEACHER REGISTER ERROR');
      print(e);

      emit(
        StaffRegisterError(e.toString()),
      );
    }
  }
}
