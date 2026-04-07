import 'package:equatable/equatable.dart';
import 'package:classfury/features/batches/data/models/batch_model.dart';

abstract class BatchesState extends Equatable {
  const BatchesState();
  
  @override
  List<Object?> get props => [];
}

class BatchesInitial extends BatchesState {}

class BatchesLoading extends BatchesState {}

class BatchesLoaded extends BatchesState {
  final List<BatchModel> batches;
  const BatchesLoaded(this.batches);
  
  @override
  List<Object?> get props => [batches];
}

class BatchCreated extends BatchesState {
  final BatchModel batch;
  const BatchCreated(this.batch);
  
  @override
  List<Object?> get props => [batch];
}

class BatchJoined extends BatchesState {}

class BatchRequestSent extends BatchesState {}

class BatchesError extends BatchesState {
  final String message;
  const BatchesError(this.message);
  
  @override
  List<Object?> get props => [message];
}
