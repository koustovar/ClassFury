import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:classfury/app/theme/app_colors.dart';
import 'package:classfury/app/theme/app_typography.dart';
import 'package:classfury/core/widgets/custom_button.dart';
import 'package:classfury/core/widgets/loading_overlay.dart';
import 'package:classfury/core/di/injection.dart';
import 'package:classfury/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:classfury/features/batches/data/repositories/batches_repository_impl.dart';
import 'package:classfury/features/batches/presentation/bloc/batches_cubit.dart';
import 'package:classfury/features/batches/presentation/bloc/batches_state.dart';
import 'package:classfury/features/attendance/data/models/attendance_model.dart';
import 'package:classfury/features/attendance/presentation/bloc/attendance_cubit.dart';
import 'package:classfury/features/attendance/presentation/bloc/attendance_state.dart';
import 'package:classfury/features/attendance/data/repositories/attendance_repository_impl.dart';

class TakeAttendancePage extends StatefulWidget {
  const TakeAttendancePage({super.key});

  @override
  State<TakeAttendancePage> createState() => _TakeAttendancePageState();
}

class _TakeAttendancePageState extends State<TakeAttendancePage> {
  String? _selectedBatchId;
  final List<AttendanceRecord> _tempRecords = [];

  void _onBatchChanged(String? batchId, List<String> studentIds) {
    setState(() {
      _selectedBatchId = batchId;
      _tempRecords.clear();
      for (var id in studentIds) {
        _tempRecords.add(AttendanceRecord(
          studentId: id,
          studentName: 'Student ${id.substring(0, 4)}', // Ideally would fetch real names
          isPresent: true,
        ));
      }
    });
  }

  void _onToggle(int index) {
    setState(() {
      _tempRecords[index] = AttendanceRecord(
        studentId: _tempRecords[index].studentId,
        studentName: _tempRecords[index].studentName,
        isPresent: !_tempRecords[index].isPresent,
      );
    });
  }

  void _onSubmit() {
    if (_selectedBatchId != null && _tempRecords.isNotEmpty) {
      final authState = context.read<AuthBloc>().state;
      final teacherId = authState is AuthAuthenticated ? authState.user.uid : '';

      context.read<AttendanceCubit>().submitAttendance(
        batchId: _selectedBatchId!,
        teacherId: teacherId,
        records: _tempRecords,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final teacherId = authState is AuthAuthenticated ? authState.user.uid : '';

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AttendanceCubit(getIt<AttendanceRepository>())),
        BlocProvider(create: (context) => BatchesCubit(getIt<BatchesRepository>())..loadBatches(teacherId)),
      ],
      child: BlocListener<AttendanceCubit, AttendanceState>(
        listener: (context, state) {
          if (state is AttendanceSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attendance recorded successfully!')));
            context.pop();
          } else if (state is AttendanceError) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.error));
          }
        },
        child: BlocBuilder<AttendanceCubit, AttendanceState>(
          builder: (context, state) {
            return LoadingOverlay(
              isLoading: state is AttendanceLoading,
              child: Scaffold(
                appBar: AppBar(title: const Text('Take Attendance')),
                body: Column(
                  children: [
                    _buildBatchSelector(),
                    const Divider(height: 1),
                    Expanded(
                      child: _tempRecords.isEmpty 
                        ? const Center(child: Text('Select a batch to see students'))
                        : _buildStudentList(),
                    ),
                    if (_tempRecords.isNotEmpty) _buildSubmitButton(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBatchSelector() {
    return BlocBuilder<BatchesCubit, BatchesState>(
      builder: (context, state) {
        if (state is BatchesLoaded) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              value: _selectedBatchId,
              hint: const Text('Select Batch'),
              items: state.batches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
              onChanged: (v) {
                final batch = state.batches.firstWhere((b) => b.id == v);
                _onBatchChanged(v, batch.studentIds);
              },
            ),
          );
        }
        return const LinearProgressIndicator();
      },
    );
  }

  Widget _buildStudentList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _tempRecords.length,
      separatorBuilder: (_, __) => const Gap(12),
      itemBuilder: (context, index) {
        final record = _tempRecords[index];
        return ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.divider)),
          leading: CircleAvatar(child: Text(record.studentName[0])),
          title: Text(record.studentName),
          trailing: Switch(
            value: record.isPresent,
            onChanged: (_) => _onToggle(index),
            activeColor: AppColors.green,
          ),
          onTap: () => _onToggle(index),
        );
      },
    );
  }

  Widget _buildSubmitButton() {
    final present = _tempRecords.where((r) => r.isPresent).length;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Present: $present / ${_tempRecords.length}', style: AppTypography.labelLarge),
          const Gap(12),
          CustomButton(label: 'Submit Attendance', onPressed: _onSubmit),
        ],
      ),
    );
  }
}
