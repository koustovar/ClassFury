import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../models/class_model.dart';
import '../datasources/classes_remote_datasource.dart';

abstract class ClassesRepository {
  Future<Either<Failure, ClassModel>> scheduleClass(ClassModel classData);
  Future<Either<Failure, List<ClassModel>>> getBatchClasses(String batchId);
  Future<Either<Failure, List<ClassModel>>> getTeacherClasses(String teacherId);
  Future<Either<Failure, void>> updateClassStatus(String classId, bool isLive);
  Future<Either<Failure, void>> deleteClass(String classId);
}

class ClassesRepositoryImpl implements ClassesRepository {
  final ClassesRemoteDataSource _remoteDataSource;

  ClassesRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, ClassModel>> scheduleClass(ClassModel classData) async {
    try {
      final result = await _remoteDataSource.scheduleClass(classData);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ClassModel>>> getBatchClasses(String batchId) async {
    try {
      final result = await _remoteDataSource.getBatchClasses(batchId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ClassModel>>> getTeacherClasses(String teacherId) async {
    try {
      final result = await _remoteDataSource.getTeacherClasses(teacherId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateClassStatus(String classId, bool isLive) async {
    try {
      await _remoteDataSource.updateClassStatus(classId, isLive);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteClass(String classId) async {
    try {
      await _remoteDataSource.deleteClass(classId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
