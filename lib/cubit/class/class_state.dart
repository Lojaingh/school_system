// lib/cubit/class/class_state.dart

part of 'class_cubit.dart';

abstract class ClassState {}

class ClassInitial extends ClassState {}

class ClassLoading extends ClassState {}

class ClassLoaded extends ClassState {
  final List<SchoolClass> classes;

  ClassLoaded(this.classes);
}

class ClassEmpty extends ClassState {} // ✅ حالة جديدة للقائمة الفارغة

class ClassError extends ClassState {
  final String message;

  ClassError(this.message);
}
