import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:classfury/features/notices/data/models/notice_model.dart';
import 'package:classfury/features/notices/data/repositories/notices_repository_impl.dart';
import 'notices_state.dart';
export 'notices_state.dart';

class NoticesCubit extends Cubit<NoticesState> {
  final NoticesRepository _repository;

  NoticesCubit(this._repository) : super(NoticesInitial());

  Future<void> loadBatchNotices(String batchId) async {
    emit(NoticesLoading());
    final result = await _repository.getBatchNotices(batchId);
    result.fold(
      (failure) => emit(NoticesError(failure.message)),
      (notices) => emit(NoticesLoaded(notices)),
    );
  }

  Future<void> createNotice({
    required String batchId,
    required String teacherId,
    required String title,
    required String content,
    List<String> attachmentUrls = const [],
  }) async {
    emit(NoticesLoading());
    final result = await _repository.createNotice(NoticeModel(
      id: '',
      batchId: batchId,
      teacherId: teacherId,
      title: title,
      content: content,
      createdAt: DateTime.now(),
      attachmentUrls: attachmentUrls,
    ));
    
    result.fold(
      (failure) => emit(NoticesError(failure.message)),
      (notice) => emit(NoticeCreated(notice)),
    );
  }
}
