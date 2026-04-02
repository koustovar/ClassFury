import 'package:equatable/equatable.dart';
import '../../data/repositories/analytics_repository_impl.dart';

abstract class ProgressState extends Equatable {
  const ProgressState();
  
  @override
  List<Object?> get props => [];
}

class ProgressInitial extends ProgressState {}

class ProgressLoading extends ProgressState {}

class ProgressLoaded extends ProgressState {
  final BatchAnalytics analytics;
  const ProgressLoaded(this.analytics);
  
  @override
  List<Object?> get props => [analytics];
}

class ProgressError extends ProgressState {
  final String message;
  const ProgressError(this.message);
  
  @override
  List<Object?> get props => [message];
}
