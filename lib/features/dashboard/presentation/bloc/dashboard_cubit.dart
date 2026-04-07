import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:classfury/features/batches/data/repositories/batches_repository_impl.dart';
import 'package:classfury/features/exams/data/repositories/exams_repository_impl.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final BatchesRepository _batchesRepository;
  final ExamsRepository _examsRepository;
  StreamSubscription? _batchesSubscription;

  DashboardCubit(this._batchesRepository, this._examsRepository)
      : super(const DashboardState(
          totalBatches: 0,
          totalStudents: 0,
          totalExams: 0,
          isLoading: false,
        ));

  Future<void> loadDashboardData(String teacherId) async {
    emit(state.copyWith(isLoading: true));

    await _batchesSubscription?.cancel();
    _batchesSubscription =
        _batchesRepository.watchTeacherBatches(teacherId).listen(
      (batches) async {
        int totalStudents = 0;
        for (final batch in batches) {
          totalStudents += (batch.studentCount as num).toInt();
        }

        // Fetch actual exam count for this teacher
        int totalExams = 0;
        final examsResult = await _examsRepository.getTeacherExams(teacherId);
        examsResult.fold(
          (failure) {
            // Use 0 if fetching fails, error is logged elsewhere
            totalExams = 0;
          },
          (exams) {
            totalExams = exams.length;
          },
        );

        emit(state.copyWith(
          totalBatches: batches.length,
          totalStudents: totalStudents,
          totalExams: totalExams,
          isLoading: false,
        ));
      },
      onError: (error) {
        emit(state.copyWith(isLoading: false));
      },
    );
  }

  @override
  Future<void> close() {
    _batchesSubscription?.cancel();
    return super.close();
  }
}
