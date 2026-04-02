import 'package:equatable/equatable.dart';
import 'package:classfury/features/attendance/data/models/attendance_model.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();
  
  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final List<AttendanceModel> history;
  const AttendanceLoaded(this.history);
  
  @override
  List<Object?> get props => [history];
}

class AttendanceSubmitted extends AttendanceState {}

class AttendanceError extends AttendanceState {
  final String message;
  const AttendanceError(this.message);
  
  @override
  List<Object?> get props => [message];
}
