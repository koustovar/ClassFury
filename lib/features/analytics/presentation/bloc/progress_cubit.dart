import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/analytics_repository_impl.dart';
import 'progress_state.dart';
export 'progress_state.dart';

class ProgressCubit extends Cubit<ProgressState> {
  final AnalyticsRepository _repository;

  ProgressCubit(this._repository) : super(ProgressInitial());

  Future<void> loadBatchAnalytics(String batchId) async {
    emit(ProgressLoading());
    final result = await _repository.getBatchAnalytics(batchId);
    result.fold(
      (failure) => emit(ProgressError(failure.message)),
      (analytics) => emit(ProgressLoaded(analytics)),
    );
  }
}
