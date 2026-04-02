import 'package:dartz/dartz.dart';
import 'package:classfury/core/errors/failures.dart';
import 'package:classfury/features/exams/data/repositories/exams_repository_impl.dart';
import 'package:classfury/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:classfury/features/exams/data/models/exam_model.dart';
import 'package:classfury/features/attendance/data/models/attendance_model.dart';

class BatchAnalytics {
  final double averageAttendance;
  final double averageExamScore;
  final List<double> attendanceTrend;
  final List<double> examTrend;

  BatchAnalytics({
    required this.averageAttendance,
    required this.averageExamScore,
    required this.attendanceTrend,
    required this.examTrend,
  });
}

abstract class AnalyticsRepository {
  Future<Either<Failure, BatchAnalytics>> getBatchAnalytics(String batchId);
}

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final ExamsRepository _examsRepository;
  final AttendanceRepository _attendanceRepository;

  AnalyticsRepositoryImpl(this._examsRepository, this._attendanceRepository);

  @override
  Future<Either<Failure, BatchAnalytics>> getBatchAnalytics(String batchId) async {
    try {
      final examsResult = await _examsRepository.getBatchExams(batchId);
      final attendanceResult = await _attendanceRepository.getBatchAttendance(batchId);

      return examsResult.fold(
        (failure) => Left(failure),
        (exams) => attendanceResult.fold(
          (failure) => Left(failure),
          (attendance) {
            final avgAttendance = _calculateAvgAttendance(attendance);
            final avgExam = _calculateAvgExam(exams);
            
            return Right(BatchAnalytics(
              averageAttendance: avgAttendance,
              averageExamScore: avgExam,
              attendanceTrend: attendance.take(7).map((a) => (a.presentCount / a.totalCount) * 100).toList().reversed.toList(),
              examTrend: exams.take(7).map((e) => (e.totalMarks > 0 ? 80.0 : 0.0)).toList(), // Simplified for now
            ));
          },
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  double _calculateAvgAttendance(List<AttendanceModel> history) {
    if (history.isEmpty) return 0.0;
    final total = history.fold(0, (sum, a) => sum + (a.totalCount > 0 ? (a.presentCount / a.totalCount * 100).toInt() : 0));
    return total / history.length;
  }

  double _calculateAvgExam(List<ExamModel> exams) {
    if (exams.isEmpty) return 0.0;
    // Real logic would involve fetching student scores, for now simplified
    return 85.5; 
  }
}
