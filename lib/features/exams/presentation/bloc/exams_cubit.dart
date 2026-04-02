import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:classfury/features/exams/data/models/exam_model.dart';
import 'package:classfury/features/exams/data/repositories/exams_repository_impl.dart';
import 'exams_state.dart';

class ExamsCubit extends Cubit<ExamsState> {
  final ExamsRepository _repository;

  ExamsCubit(this._repository) : super(ExamsInitial());

  Future<void> loadBatchExams(String batchId) async {
    emit(ExamsLoading());
    final result = await _repository.getBatchExams(batchId);
    result.fold(
      (failure) => emit(ExamsError(failure.message)),
      (exams) => emit(ExamsLoaded(exams)),
    );
  }

  Future<void> createExam(ExamModel exam) async {
    emit(ExamsLoading());
    final result = await _repository.createExam(exam);
    result.fold(
      (failure) => emit(ExamsError(failure.message)),
      (createdExam) => emit(ExamCreated(createdExam)),
    );
  }

  Future<void> updateStatus(String examId, ExamStatus status) async {
    final result = await _repository.updateExamStatus(examId, status);
    result.fold(
      (failure) => emit(ExamsError(failure.message)),
      (_) {
        // Reloading is handled by the UI or separate call
      },
    );
  }
}
