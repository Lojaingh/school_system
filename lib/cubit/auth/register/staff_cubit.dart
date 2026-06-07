import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management/data/model/staff_model.dart';
import 'package:school_management/data/repository/staff_repository.dart';

import 'staff_state.dart';

class StaffCubit extends Cubit<StaffRegisterState> {
  final StaffRepository repository;

  StaffCubit(this.repository) : super(StaffRegisterInitial());

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

      emit(StaffRegisterError(e.toString()));
    }
  }
}
