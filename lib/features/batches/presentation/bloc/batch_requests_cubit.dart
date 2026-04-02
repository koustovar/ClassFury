import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:classfury/features/batches/data/repositories/batches_repository_impl.dart';
import 'batch_requests_state.dart';

class BatchRequestsCubit extends Cubit<BatchRequestsState> {
  final BatchesRepository _repository;
  StreamSubscription? _requestsSubscription;

  BatchRequestsCubit(this._repository) : super(BatchRequestsInitial());

  Future<void> watchBatchRequests({String? teacherId, String? batchId, String? studentId}) async {
    emit(BatchRequestsLoading());
    await _requestsSubscription?.cancel();
    _requestsSubscription = _repository.watchBatchRequests(
      teacherId: teacherId, 
      batchId: batchId, 
      studentId: studentId,
    ).listen(
      (requests) => emit(BatchRequestsLoaded(requests)),
      onError: (error) => emit(BatchRequestsError(error.toString())),
    );
  }

  Future<void> respondToJoinRequest(String requestId, bool accept) async {
    emit(BatchRequestsLoading());
    final result = await _repository.respondToBatchRequest(requestId, accept);
    result.fold(
      (failure) => emit(BatchRequestsError(failure.message)),
      (_) => emit(BatchRequestResponded()),
    );
  }

  @override
  Future<void> close() {
    _requestsSubscription?.cancel();
    return super.close();
  }
}
