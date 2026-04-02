import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:classfury/features/classes/data/models/class_model.dart';
import 'package:classfury/features/classes/data/repositories/classes_repository_impl.dart';
import 'classes_state.dart';

class ClassesCubit extends Cubit<ClassesState> {
  final ClassesRepository _repository;

  ClassesCubit(this._repository) : super(ClassesInitial());

  Future<void> loadBatchClasses(String batchId) async {
    emit(ClassesLoading());
    final result = await _repository.getBatchClasses(batchId);
    result.fold(
      (failure) => emit(ClassesError(failure.message)),
      (classes) => emit(ClassesLoaded(classes)),
    );
  }

  Future<void> scheduleClass(ClassModel classData) async {
    emit(ClassesLoading());
    final result = await _repository.scheduleClass(classData);
    result.fold(
      (failure) => emit(ClassesError(failure.message)),
      (scheduled) => emit(ClassScheduled(scheduled)),
    );
  }

  Future<void> toggleLive(String classId, bool isLive) async {
    final result = await _repository.updateClassStatus(classId, isLive);
    result.fold(
      (failure) => emit(ClassesError(failure.message)),
      (_) {},
    );
  }
}
