import 'package:dartz/dartz.dart';
import 'package:classfury/core/errors/failures.dart';
import '../models/batch_model.dart';
import '../models/batch_request_model.dart';
import '../datasources/batches_remote_datasource.dart';

abstract class BatchesRepository {
  Future<Either<Failure, BatchModel>> createBatch(BatchModel batch);
  Future<Either<Failure, List<BatchModel>>> getTeacherBatches(String teacherId);
  Stream<List<BatchModel>> watchTeacherBatches(String teacherId);
  Future<Either<Failure, List<BatchModel>>> getStudentBatches(String studentId);
  Stream<List<BatchModel>> watchStudentBatches(String studentId);
  Future<Either<Failure, BatchModel>> getBatchByJoinCode(String joinCode);
  Future<Either<Failure, void>> requestToJoinBatch(String studentId, String studentName, String batchId);
  Future<Either<Failure, void>> respondToBatchRequest(String requestId, bool accept);
  Future<Either<Failure, void>> deleteBatch(String batchId, String teacherId);
  Stream<List<BatchRequestModel>> watchBatchRequests({String? teacherId, String? batchId, String? studentId});
  Future<Either<Failure, List<BatchRequestModel>>> getBatchRequests({String? teacherId, String? batchId, String? studentId});
}

class BatchesRepositoryImpl implements BatchesRepository {
  final BatchesRemoteDataSource _remoteDataSource;

  BatchesRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, BatchModel>> createBatch(BatchModel batch) async {
    try {
      final result = await _remoteDataSource.createBatch(batch);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BatchModel>>> getTeacherBatches(String teacherId) async {
    try {
      final result = await _remoteDataSource.getTeacherBatches(teacherId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<BatchModel>> watchTeacherBatches(String teacherId) {
    return _remoteDataSource.watchTeacherBatches(teacherId);
  }

  @override
  Future<Either<Failure, List<BatchModel>>> getStudentBatches(String studentId) async {
    try {
      final result = await _remoteDataSource.getStudentBatches(studentId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<BatchModel>> watchStudentBatches(String studentId) {
    return _remoteDataSource.watchStudentBatches(studentId);
  }

  @override
  Future<Either<Failure, BatchModel>> getBatchByJoinCode(String joinCode) async {
    try {
      final result = await _remoteDataSource.getBatchByJoinCode(joinCode);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> requestToJoinBatch(String studentId, String studentName, String batchId) async {
    try {
      await _remoteDataSource.requestToJoinBatch(studentId, studentName, batchId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BatchRequestModel>>> getBatchRequests({String? teacherId, String? batchId, String? studentId}) async {
    try {
      final result = await _remoteDataSource.getBatchRequests(teacherId: teacherId, batchId: batchId, studentId: studentId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> respondToBatchRequest(String requestId, bool accept) async {
    try {
      await _remoteDataSource.respondToBatchRequest(requestId, accept);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBatch(String batchId, String teacherId) async {
    try {
      await _remoteDataSource.deleteBatch(batchId, teacherId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<BatchRequestModel>> watchBatchRequests({String? teacherId, String? batchId, String? studentId}) {
    return _remoteDataSource.watchBatchRequests(teacherId: teacherId, batchId: batchId, studentId: studentId);
  }
}
