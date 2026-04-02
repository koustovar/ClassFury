import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../models/attendance_model.dart';
import '../datasources/attendance_remote_datasource.dart';

abstract class AttendanceRepository {
  Future<Either<Failure, void>> submitAttendance(AttendanceModel attendance);
  Future<Either<Failure, List<AttendanceModel>>> getBatchAttendance(String batchId);
}

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource _remoteDataSource;

  AttendanceRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, void>> submitAttendance(AttendanceModel attendance) async {
    try {
      if (attendance.records.isEmpty) return Left(ServerFailure('No student records to submit'));
      await _remoteDataSource.submitAttendance(attendance);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AttendanceModel>>> getBatchAttendance(String batchId) async {
    try {
      final result = await _remoteDataSource.getBatchAttendance(batchId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
