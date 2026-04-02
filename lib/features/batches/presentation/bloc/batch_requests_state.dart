import 'package:equatable/equatable.dart';
import 'package:classfury/features/batches/data/models/batch_request_model.dart';

abstract class BatchRequestsState extends Equatable {
  const BatchRequestsState();
  
  @override
  List<Object?> get props => [];
}

class BatchRequestsInitial extends BatchRequestsState {}

class BatchRequestsLoading extends BatchRequestsState {}

class BatchRequestsLoaded extends BatchRequestsState {
  final List<BatchRequestModel> requests;
  const BatchRequestsLoaded(this.requests);
  
  @override
  List<Object?> get props => [requests];
}

class BatchRequestResponded extends BatchRequestsState {}

class BatchRequestsError extends BatchRequestsState {
  final String message;
  const BatchRequestsError(this.message);
  
  @override
  List<Object?> get props => [message];
}
