import '../../data/model/staff_profile_model.dart';

abstract class StaffProfileState {}

class StaffInitial extends StaffProfileState {}

class StaffLoading extends StaffProfileState {}

class StaffLoaded extends StaffProfileState {
  final List<StaffProfileModel> staff;

  StaffLoaded(this.staff);
}

class StaffError extends StaffProfileState {
  final String message;

  StaffError(this.message);
}

class StaffProfileLoaded extends StaffProfileState {
  final StaffProfileModel staff;

  StaffProfileLoaded(this.staff);
}
