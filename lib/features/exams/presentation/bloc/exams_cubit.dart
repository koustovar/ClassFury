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

  Future<void> createExam(ExamModel exam, {dynamic questionFile}) async {
    emit(ExamsLoading());
    
    ExamModel finalExam = exam;
    if (questionFile != null) {
      final uploadResult = await _repository.uploadExamFile(exam.id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : exam.id, questionFile);
      uploadResult.fold(
        (failure) => emit(ExamsError(failure.message)),
        (url) {
          finalExam = ExamModel(
            id: exam.id,
            batchId: exam.batchId,
            teacherId: exam.teacherId,
            title: exam.title,
            description: exam.description,
            startTime: exam.startTime,
            durationMinutes: exam.durationMinutes,
            gracePeriodMinutes: exam.gracePeriodMinutes,
            questionUrl: url,
            questions: exam.questions,
            status: exam.status,
            totalMarks: exam.totalMarks,
            createdAt: exam.createdAt,
          );
        }
      );
      if (state is ExamsError) return;
    }

    final result = await _repository.createExam(finalExam);
    result.fold(
      (failure) => emit(ExamsError(failure.message)),
      (createdExam) => emit(ExamCreated(createdExam)),
    );
  }

  Future<void> submitAnswer(Map<String, dynamic> submission) async {
    emit(ExamsLoading());
    final result = await _repository.submitExamAnswer(submission);
    result.fold(
      (failure) => emit(ExamsError(failure.message)),
      (_) => emit(ExamSubmitted()),
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
