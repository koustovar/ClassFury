import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../models/notice_model.dart';
import '../datasources/notices_remote_datasource.dart';

abstract class NoticesRepository {
  Future<Either<Failure, NoticeModel>> createNotice(NoticeModel notice);
  Future<Either<Failure, List<NoticeModel>>> getBatchNotices(String batchId);
  Future<Either<Failure, List<NoticeModel>>> getTeacherNotices(String teacherId);
  Future<Either<Failure, void>> deleteNotice(String noticeId);
  Stream<List<NoticeModel>> watchStudentNotices(List<String> batchIds);
}

class NoticesRepositoryImpl implements NoticesRepository {
  final NoticesRemoteDataSource _remoteDataSource;

  NoticesRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, NoticeModel>> createNotice(NoticeModel notice) async {
    try {
      final result = await _remoteDataSource.createNotice(notice);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NoticeModel>>> getBatchNotices(String batchId) async {
    try {
      final result = await _remoteDataSource.getBatchNotices(batchId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NoticeModel>>> getTeacherNotices(String teacherId) async {
    try {
      final result = await _remoteDataSource.getTeacherNotices(teacherId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotice(String noticeId) async {
    try {
      await _remoteDataSource.deleteNotice(noticeId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<NoticeModel>> watchStudentNotices(List<String> batchIds) {
    return _remoteDataSource.watchStudentNotices(batchIds);
  }
}
