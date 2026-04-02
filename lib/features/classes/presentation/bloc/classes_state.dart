import 'package:equatable/equatable.dart';
import 'package:classfury/features/classes/data/models/class_model.dart';

abstract class ClassesState extends Equatable {
  const ClassesState();
  
  @override
  List<Object?> get props => [];
}

class ClassesInitial extends ClassesState {}

class ClassesLoading extends ClassesState {}

class ClassesLoaded extends ClassesState {
  final List<ClassModel> classes;
  const ClassesLoaded(this.classes);
  
  @override
  List<Object?> get props => [classes];
}

class ClassScheduled extends ClassesState {
  final ClassModel classData;
  const ClassScheduled(this.classData);
  
  @override
  List<Object?> get props => [classData];
}

class ClassesError extends ClassesState {
  final String message;
  const ClassesError(this.message);
  
  @override
  List<Object?> get props => [message];
}
