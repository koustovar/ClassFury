import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:classfury/features/notices/data/models/notice_model.dart';
import 'package:classfury/features/notices/data/repositories/notices_repository_impl.dart';
import 'notices_state.dart';
export 'notices_state.dart';

class NoticesCubit extends Cubit<NoticesState> {
  final NoticesRepository _repository;
  StreamSubscription? _noticesSubscription;
  DateTime? _latestNoticeTime;

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
    required String batchName,
    required String teacherId,
    required String title,
    required String content,
    List<String> attachmentUrls = const [],
  }) async {
    emit(NoticesLoading());
    final result = await _repository.createNotice(NoticeModel(
      id: '',
      batchId: batchId,
      batchName: batchName,
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

  void watchStudentNotices(List<String> batchIds) {
    if (batchIds.isEmpty) {
      emit(const NoticesLoaded([]));
      return;
    }

    emit(NoticesLoading());
    _noticesSubscription?.cancel();
    
    _noticesSubscription = _repository.watchStudentNotices(batchIds).listen(
      (notices) async {
        // Find if there is a new notice
        bool isNew = false;
        if (notices.isNotEmpty) {
          final mostRecent = notices.first.createdAt;
          if (_latestNoticeTime != null && mostRecent.isAfter(_latestNoticeTime!)) {
            isNew = true;
          }
          _latestNoticeTime = mostRecent;
        }

        if (isNew) {
           try {
             FlutterRingtonePlayer().playNotification();
           } catch (_) {}
        }
        
        emit(NoticesLoaded(notices));
      },
      onError: (error) => emit(NoticesError(error.toString())),
    );
  }

  @override
  Future<void> close() {
    _noticesSubscription?.cancel();
    return super.close();
  }
}
