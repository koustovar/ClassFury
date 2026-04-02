import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:classfury/features/batches/data/repositories/batches_repository_impl.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final BatchesRepository _batchesRepository;
  StreamSubscription? _batchesSubscription;

  DashboardCubit(this._batchesRepository) : super(const DashboardState(
    totalBatches: 0,
    totalStudents: 0,
    totalExams: 0,
    isLoading: false,
  ));

  Future<void> loadDashboardData(String teacherId) async {
    emit(state.copyWith(isLoading: true));
    
    await _batchesSubscription?.cancel();
    _batchesSubscription = _batchesRepository.watchTeacherBatches(teacherId).listen(
      (batches) {
        int totalStudents = 0;
        for (final batch in batches) {
          totalStudents += (batch.studentCount as num).toInt();
        }
        
        emit(state.copyWith(
          totalBatches: batches.length,
          totalStudents: totalStudents,
          totalExams: 0, // TODO: Fetch from ExamsRepository
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
