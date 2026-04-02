import 'package:equatable/equatable.dart';
import 'package:classfury/features/exams/data/models/exam_model.dart';

abstract class ExamsState extends Equatable {
  const ExamsState();
  
  @override
  List<Object?> get props => [];
}

class ExamsInitial extends ExamsState {}

class ExamsLoading extends ExamsState {}

class ExamsLoaded extends ExamsState {
  final List<ExamModel> exams;
  const ExamsLoaded(this.exams);
  
  @override
  List<Object?> get props => [exams];
}

class ExamCreated extends ExamsState {
  final ExamModel exam;
  const ExamCreated(this.exam);
  
  @override
  List<Object?> get props => [exam];
}

class ExamsError extends ExamsState {
  final String message;
  const ExamsError(this.message);
  
  @override
  List<Object?> get props => [message];
}
