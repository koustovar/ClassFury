import 'package:equatable/equatable.dart';
import 'package:classfury/features/notices/data/models/notice_model.dart';

abstract class NoticesState extends Equatable {
  const NoticesState();
  
  @override
  List<Object?> get props => [];
}

class NoticesInitial extends NoticesState {}

class NoticesLoading extends NoticesState {}

class NoticesLoaded extends NoticesState {
  final List<NoticeModel> notices;
  const NoticesLoaded(this.notices);
  
  @override
  List<Object?> get props => [notices];
}

class NoticeCreated extends NoticesState {
  final NoticeModel notice;
  const NoticeCreated(this.notice);
  
  @override
  List<Object?> get props => [notice];
}

class NoticesError extends NoticesState {
  final String message;
  const NoticesError(this.message);
  
  @override
  List<Object?> get props => [message];
}
