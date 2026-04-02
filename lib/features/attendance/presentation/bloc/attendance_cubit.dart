import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:classfury/features/attendance/data/models/attendance_model.dart';
import 'package:classfury/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'attendance_state.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  final AttendanceRepository _repository;

  AttendanceCubit(this._repository) : super(AttendanceInitial());

  Future<void> loadBatchAttendance(String batchId) async {
    emit(AttendanceLoading());
    final result = await _repository.getBatchAttendance(batchId);
    result.fold(
      (failure) => emit(AttendanceError(failure.message)),
      (history) => emit(AttendanceLoaded(history)),
    );
  }

  Future<void> submitAttendance({
    required String batchId,
    required String teacherId,
    required List<AttendanceRecord> records,
  }) async {
    emit(AttendanceLoading());
    
    final presentCount = records.where((r) => r.isPresent).length;
    
    final attendance = AttendanceModel(
      id: '',
      batchId: batchId,
      teacherId: teacherId,
      date: DateTime.now(),
      records: records,
      presentCount: presentCount,
      totalCount: records.length,
    );

    final result = await _repository.submitAttendance(attendance);
    result.fold(
      (failure) => emit(AttendanceError(failure.message)),
      (_) => emit(AttendanceSubmitted()),
    );
  }
}
