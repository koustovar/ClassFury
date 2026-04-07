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
import 'package:classfury/features/batches/data/models/batch_model.dart';
import 'package:classfury/features/batches/data/repositories/batches_repository_impl.dart';
import 'package:classfury/features/batches/presentation/bloc/batches_cubit.dart';
import 'package:classfury/features/exams/data/models/exam_model.dart';
import 'package:classfury/features/exams/presentation/bloc/exams_cubit.dart';
import 'package:classfury/features/exams/presentation/bloc/exams_state.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:classfury/features/exams/data/repositories/exams_repository_impl.dart';

class CreateExamPage extends StatefulWidget {
  final BatchModel? batch;
  const CreateExamPage({super.key, this.batch});

  @override
  State<CreateExamPage> createState() => _CreateExamPageState();
}

class _CreateExamPageState extends State<CreateExamPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  String? _selectedBatchId;
  DateTime? _selectedStartTime;

  final _gracePeriodController = TextEditingController(text: '10');
  File? _questionFile;
  String? _questionFileName;

  @override
  void initState() {
    super.initState();
    if (widget.batch != null) {
      _selectedBatchId = widget.batch!.id;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _gracePeriodController.dispose();
    super.dispose();
  }

  Future<void> _pickQuestionFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        setState(() {
          _questionFile = File(result.files.single.path!);
          _questionFileName = result.files.single.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  void _onSave(BuildContext context) {
    if (_formKey.currentState!.validate() &&
        _selectedBatchId != null &&
        _selectedStartTime != null) {
      if (_questionFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please upload a question paper')));
        return;
      }

      final authState = context.read<AuthBloc>().state;
      final teacherId =
          authState is AuthAuthenticated ? authState.user.uid : '';

      final exam = ExamModel(
        id: '',
        batchId: _selectedBatchId!,
        teacherId: teacherId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        startTime: _selectedStartTime!,
        durationMinutes: int.parse(_durationController.text),
        gracePeriodMinutes: int.tryParse(_gracePeriodController.text) ?? 10,
        questionUrl: null, // will be populated by cubit
        questions: const [],
        status: ExamStatus.upcoming,
        totalMarks: 100, // Or some field
        createdAt: DateTime.now(),
      );

      context.read<ExamsCubit>().createExam(exam, questionFile: _questionFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ExamsCubit(getIt<ExamsRepository>())),
        BlocProvider(create: (context) {
          final authState = context.read<AuthBloc>().state;
          final teacherId =
              authState is AuthAuthenticated ? authState.user.uid : '';
          return BatchesCubit(getIt<BatchesRepository>())
            ..loadBatches(teacherId);
        }),
      ],
      child: BlocListener<ExamsCubit, ExamsState>(
        listener: (context, state) {
          if (state is ExamCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exam created successfully!')));
            context.pop(true);
          } else if (state is ExamsError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error));
          }
        },
        child: BlocBuilder<ExamsCubit, ExamsState>(
          builder: (context, state) {
            return LoadingOverlay(
              isLoading: state is ExamsLoading,
              child: Scaffold(
                appBar: AppBar(title: const Text('Create Exam')),
                body: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      _buildBasicInfo(context),
                      const Gap(32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Question Paper', style: AppTypography.h3),
                          TextButton.icon(
                            onPressed: _pickQuestionFile,
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Upload PDF/Image'),
                          ),
                        ],
                      ),
                      if (_questionFileName != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('Selected: $_questionFileName',
                              style: const TextStyle(color: Colors.green)),
                        ),
                      const Gap(48),
                      CustomButton(
                          label: 'Create Exam',
                          onPressed: () => _onSave(context)),
                      const Gap(24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBasicInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Select Batch', style: AppTypography.labelLarge),
        const Gap(12),
        BlocBuilder<BatchesCubit, BatchesState>(
          builder: (context, batchState) {
            if (batchState is BatchesLoaded) {
              return DropdownButtonFormField<String>(
                initialValue: _selectedBatchId,
                hint: const Text('Choose a batch'),
                items: batchState.batches
                    .map((b) =>
                        DropdownMenuItem(value: b.id, child: Text(b.name)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedBatchId = v),
                validator: (v) => v == null ? 'Required' : null,
              );
            }
            return const Center(child: LinearProgressIndicator());
          },
        ),
        const Gap(20),
        CustomTextField(
          label: 'Exam Title',
          hint: 'e.g. Midterm Mathematics',
          controller: _titleController,
          validator: (v) => AppValidators.validateRequired(v, 'Title'),
        ),
        const Gap(20),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Duration (Mins)',
                hint: '60',
                controller: _durationController,
                keyboardType: TextInputType.number,
                validator: (v) => AppValidators.validateRequired(v, 'Duration'),
              ),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Start Time', style: AppTypography.labelLarge),
                  const Gap(8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null && context.mounted) {
                        final time = await showTimePicker(
                            context: context, initialTime: TimeOfDay.now());
                        if (time != null) {
                          setState(() {
                            _selectedStartTime = DateTime(date.year, date.month,
                                date.day, time.hour, time.minute);
                          });
                        }
                      }
                    },
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label:
                        Text(_selectedStartTime == null ? 'Pick' : 'Selected'),
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Gap(20),
        CustomTextField(
          label: 'Grace Period (Mins)',
          hint: '10',
          controller: _gracePeriodController,
          keyboardType: TextInputType.number,
          validator: (v) => AppValidators.validateRequired(v, 'Grace Period'),
        ),
      ],
    );
  }
}
