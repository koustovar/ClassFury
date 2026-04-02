import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:classfury/features/batches/data/models/batch_model.dart';
import 'package:classfury/features/batches/data/models/batch_request_model.dart';
import 'package:classfury/features/batches/data/repositories/batches_repository_impl.dart';
import 'batches_state.dart';
export 'batches_state.dart';

class BatchesCubit extends Cubit<BatchesState> {
  final BatchesRepository _repository;
  StreamSubscription? _batchesSubscription;

  BatchesCubit(this._repository) : super(BatchesInitial());

  Future<void> loadBatches(String teacherId) async {
    emit(BatchesLoading());
    await _batchesSubscription?.cancel();
    _batchesSubscription = _repository.watchTeacherBatches(teacherId).listen(
      (batches) => emit(BatchesLoaded(batches)),
      onError: (error) => emit(BatchesError(error.toString())),
    );
  }

  Future<void> loadStudentBatches(String studentId) async {
    emit(BatchesLoading());
    await _batchesSubscription?.cancel();
    _batchesSubscription = _repository.watchStudentBatches(studentId).listen(
      (batches) => emit(BatchesLoaded(batches)),
      onError: (error) => emit(BatchesError(error.toString())),
    );
  }

  Future<void> requestToJoinBatch({required String joinCode, required String studentId, required String studentName}) async {
    emit(BatchesLoading());
    final batchResult = await _repository.getBatchByJoinCode(joinCode);
    
    await batchResult.fold(
      (failure) async => emit(BatchesError(failure.message)),
      (batch) async {
        final result = await _repository.requestToJoinBatch(studentId, studentName, batch.id);
        result.fold(
          (failure) => emit(BatchesError(failure.message)),
          (_) => emit(BatchRequestSent()),
        );
      },
    );
  }


  Future<void> createBatch({
    required String teacherId,
    required String name,
    required String subject,
    required String description,
    required String color,
  }) async {
    emit(BatchesLoading());
    final result = await _repository.createBatch(BatchModel(
      id: '', // Will be set by data source
      teacherId: teacherId,
      name: name,
      subject: subject,
      description: description,
      joinCode: '', // Will be set by data source
      studentIds: const [],
      studentCount: 0,
      createdAt: DateTime.now(),
      color: color,
      isActive: true,
    ));
    
    result.fold(
      (failure) => emit(BatchesError(failure.message)),
      (batch) => emit(BatchCreated(batch)),
    );
  }

  Future<void> deleteBatch({required String batchId, required String teacherId}) async {
    emit(BatchesLoading());
    final result = await _repository.deleteBatch(batchId, teacherId);
    result.fold(
      (failure) => emit(BatchesError(failure.message)),
      (_) => emit(BatchesInitial()), // Emit initial to trigger list refresh
    );
  }

  @override
  Future<void> close() {
    _batchesSubscription?.cancel();
    return super.close();
  }
}
