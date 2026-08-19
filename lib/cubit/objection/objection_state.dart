import '../../data/model/objection_model.dart';

abstract class ObjectionState {}

class ObjectionInitial extends ObjectionState {}
class ObjectionLoading extends ObjectionState {}

class ObjectionLoaded extends ObjectionState {
  final List<ObjectionModel> objections;

  ObjectionLoaded(this.objections);
}
class ObjectionUpdateLoading extends ObjectionState {}

class ObjectionUpdateSuccess extends ObjectionState {
  final String message;

  ObjectionUpdateSuccess(this.message);
}
class ObjectionError extends ObjectionState {
  final String message;
  ObjectionError(this.message);
}
