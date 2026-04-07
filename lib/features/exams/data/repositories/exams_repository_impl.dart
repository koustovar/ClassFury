import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../models/exam_model.dart';
import '../datasources/exams_remote_datasource.dart';

abstract class ExamsRepository {
  Future<Either<Failure, ExamModel>> createExam(ExamModel exam);
  Future<Either<Failure, List<ExamModel>>> getBatchExams(String batchId);
  Future<Either<Failure, List<ExamModel>>> getTeacherExams(String teacherId);
  Future<Either<Failure, void>> updateExamStatus(String examId, ExamStatus status);
  Future<Either<Failure, void>> deleteExam(String examId);
  Future<Either<Failure, String>> uploadExamFile(String examId, dynamic file);
  Future<Either<Failure, void>> submitExamAnswer(Map<String, dynamic> submission);
}

class ExamsRepositoryImpl implements ExamsRepository {
  final ExamsRemoteDataSource _remoteDataSource;

  ExamsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, ExamModel>> createExam(ExamModel exam) async {
    try {
      final result = await _remoteDataSource.createExam(exam);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExamModel>>> getBatchExams(String batchId) async {
    try {
      final result = await _remoteDataSource.getBatchExams(batchId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExamModel>>> getTeacherExams(String teacherId) async {
    try {
      final result = await _remoteDataSource.getTeacherExams(teacherId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateExamStatus(String examId, ExamStatus status) async {
    try {
      await _remoteDataSource.updateExamStatus(examId, status);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExam(String examId) async {
    try {
      await _remoteDataSource.deleteExam(examId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadExamFile(String examId, dynamic file) async {
    try {
      final url = await _remoteDataSource.uploadExamFile(examId, file);
      return Right(url);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> submitExamAnswer(Map<String, dynamic> submission) async {
    try {
      await _remoteDataSource.submitExamAnswer(submission);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
