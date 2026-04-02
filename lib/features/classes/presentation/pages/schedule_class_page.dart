import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:classfury/app/theme/app_colors.dart';
import 'package:classfury/app/theme/app_typography.dart';
import 'package:classfury/core/widgets/custom_button.dart';
import 'package:classfury/core/widgets/custom_text_field.dart';
import 'package:classfury/core/widgets/loading_overlay.dart';
import 'package:classfury/core/utils/validators.dart';
import 'package:classfury/core/di/injection.dart';
import 'package:classfury/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:classfury/features/batches/data/repositories/batches_repository_impl.dart';
import 'package:classfury/features/batches/presentation/bloc/batches_cubit.dart';
import 'package:classfury/features/batches/presentation/bloc/batches_state.dart';
import 'package:classfury/features/classes/data/models/class_model.dart';
import 'package:classfury/features/classes/presentation/bloc/classes_cubit.dart';
import 'package:classfury/features/classes/presentation/bloc/classes_state.dart';
import 'package:classfury/features/classes/data/repositories/classes_repository_impl.dart';

class ScheduleClassPage extends StatefulWidget {
  const ScheduleClassPage({super.key});

  @override
  State<ScheduleClassPage> createState() => _ScheduleClassPageState();
}

class _ScheduleClassPageState extends State<ScheduleClassPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _linkController = TextEditingController();
  String? _selectedBatchId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _durationMins = 60;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _onSchedule() {
    if (_formKey.currentState!.validate() && _selectedBatchId != null && _selectedDate != null && _selectedTime != null) {
      final authState = context.read<AuthBloc>().state;
      final teacherId = authState is AuthAuthenticated ? authState.user.uid : '';

      final start = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _selectedTime!.hour, _selectedTime!.minute);
      final end = start.add(Duration(minutes: _durationMins));

      final classData = ClassModel(
        id: '',
        batchId: _selectedBatchId!,
        teacherId: teacherId,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        startTime: start,
        endTime: end,
        meetingLink: _linkController.text.trim(),
        isLive: false,
      );

      context.read<ClassesCubit>().scheduleClass(classData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final teacherId = authState is AuthAuthenticated ? authState.user.uid : '';

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ClassesCubit(getIt<ClassesRepository>())),
        BlocProvider(create: (context) => BatchesCubit(getIt<BatchesRepository>())..loadBatches(teacherId)),
      ],
      child: BlocListener<ClassesCubit, ClassesState>(
        listener: (context, state) {
          if (state is ClassScheduled) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Class scheduled successfully!')));
            context.pop();
          } else if (state is ClassesError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.error));
          }
        },
        child: BlocBuilder<ClassesCubit, ClassesState>(
          builder: (context, state) {
            return LoadingOverlay(
              isLoading: state is ClassesLoading,
              child: Scaffold(
                appBar: AppBar(title: const Text('Schedule Class')),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildBatchSelector(),
                        const Gap(20),
                        CustomTextField(label: 'Class Title', hint: 'e.g. Physics Chapter 5', controller: _titleController, validator: (v) => AppValidators.validateRequired(v, 'Title')),
                        const Gap(20),
                        CustomTextField(label: 'Meeting Link', hint: 'https://meet.google.com/xxx-xxxx-xxx', controller: _linkController, validator: (v) => AppValidators.validateRequired(v, 'Link')),
                        const Gap(20),
                        _buildDateTimeSelectors(context),
                        const Gap(24),
                        Text('Duration', style: AppTypography.labelLarge),
                        Slider(
                          value: _durationMins.toDouble(),
                          min: 15, max: 180, divisions: 11,
                          label: '$_durationMins mins',
                          onChanged: (v) => setState(() => _durationMins = v.toInt()),
                        ),
                        const Gap(40),
                        CustomButton(label: 'Schedule Now', onPressed: _onSchedule),
                      ],
                    ),
                  ),
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
          return DropdownButtonFormField<String>(
            value: _selectedBatchId,
            hint: const Text('Select Batch'),
            items: state.batches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
            onChanged: (v) => setState(() => _selectedBatchId = v),
          );
        }
        return const Center(child: LinearProgressIndicator());
      },
    );
  }

  Widget _buildDateTimeSelectors(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date', style: AppTypography.labelLarge),
            const Gap(8),
            OutlinedButton(
              onPressed: () async {
                final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 90)));
                if (d != null) setState(() => _selectedDate = d);
              },
              child: Text(_selectedDate == null ? 'Pick' : '${_selectedDate!.day}/${_selectedDate!.month}'),
            ),
          ],
        )),
        const Gap(16),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time', style: AppTypography.labelLarge),
            const Gap(8),
            OutlinedButton(
              onPressed: () async {
                final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                if (t != null) setState(() => _selectedTime = t);
              },
              child: Text(_selectedTime == null ? 'Pick' : _selectedTime!.format(context)),
            ),
          ],
        )),
      ],
    );
  }
}
