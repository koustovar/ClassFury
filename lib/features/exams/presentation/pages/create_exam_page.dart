import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';
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
import 'package:classfury/features/batches/presentation/bloc/batches_state.dart';
import 'package:classfury/features/exams/data/models/exam_model.dart';
import 'package:classfury/features/exams/data/models/question_model.dart';
import 'package:classfury/features/exams/presentation/bloc/exams_cubit.dart';
import 'package:classfury/features/exams/presentation/bloc/exams_state.dart';
import 'package:classfury/features/exams/data/repositories/exams_repository_impl.dart';

class CreateExamPage extends StatefulWidget {
  const CreateExamPage({super.key});

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
  
  final List<QuestionModel> _questions = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _addQuestion() {
    setState(() {
      _questions.add(QuestionModel(
        id: const Uuid().v4(),
        text: '',
        type: QuestionType.mcq,
        options: const ['', '', '', ''],
        correctAnswer: '',
        marks: 1,
      ));
    });
  }

  void _onSave() {
    if (_formKey.currentState!.validate() && _selectedBatchId != null && _selectedStartTime != null) {
      if (_questions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add at least one question')));
        return;
      }

      final authState = context.read<AuthBloc>().state;
      final teacherId = authState is AuthAuthenticated ? authState.user.uid : '';

      final exam = ExamModel(
        id: '',
        batchId: _selectedBatchId!,
        teacherId: teacherId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        startTime: _selectedStartTime!,
        durationMinutes: int.parse(_durationController.text),
        questions: _questions,
        status: ExamStatus.upcoming,
        totalMarks: _questions.fold(0, (sum, q) => sum + q.marks),
        createdAt: DateTime.now(),
      );

      context.read<ExamsCubit>().createExam(exam);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final teacherId = authState is AuthAuthenticated ? authState.user.uid : '';

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ExamsCubit(getIt<ExamsRepository>())),
        BlocProvider(create: (context) => BatchesCubit(getIt<BatchesRepository>())..loadBatches(teacherId)),
      ],
      child: BlocListener<ExamsCubit, ExamsState>(
        listener: (context, state) {
          if (state is ExamCreated) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exam created successfully!')));
            context.pop(true);
          } else if (state is ExamsError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.error));
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
                          Text('Questions (${_questions.length})', style: AppTypography.h3),
                          TextButton.icon(
                            onPressed: _addQuestion,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Question'),
                          ),
                        ],
                      ),
                      const Gap(16),
                      ..._questions.asMap().entries.map((entry) => _buildQuestionItem(entry.key, entry.value)),
                      const Gap(48),
                      CustomButton(label: 'Create Exam', onPressed: _onSave),
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
                value: _selectedBatchId,
                hint: const Text('Choose a batch'),
                items: batchState.batches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
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
                      if (date != null && mounted) {
                        final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                        if (time != null) {
                          setState(() {
                            _selectedStartTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                          });
                        }
                      }
                    },
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(_selectedStartTime == null ? 'Pick' : 'Selected'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestionItem(int index, QuestionModel q) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: AppColors.primary, radius: 14, child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 12))),
                const Gap(12),
                Expanded(child: TextFormField(
                  initialValue: q.text,
                  decoration: const InputDecoration(hintText: 'Question text...', border: InputBorder.none),
                  onChanged: (v) => _questions[index] = QuestionModel(id: q.id, text: v, type: q.type, options: q.options, correctAnswer: q.correctAnswer, marks: q.marks),
                )),
                IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => setState(() => _questions.removeAt(index))),
              ],
            ),
            const Divider(),
            ...List.generate(4, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                   Radio<String>(
                     value: '$i',
                     groupValue: q.correctAnswer,
                     onChanged: (v) => setState(() => _questions[index] = QuestionModel(id: q.id, text: q.text, type: q.type, options: q.options, correctAnswer: v!, marks: q.marks)),
                   ),
                   Expanded(child: TextFormField(
                     initialValue: q.options[i],
                     decoration: InputDecoration(hintText: 'Option ${i+1}', isDense: true),
                     onChanged: (v) {
                       final newOptions = List<String>.from(q.options);
                       newOptions[i] = v;
                       _questions[index] = QuestionModel(id: q.id, text: q.text, type: q.type, options: newOptions, correctAnswer: q.correctAnswer, marks: q.marks);
                     },
                   )),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
