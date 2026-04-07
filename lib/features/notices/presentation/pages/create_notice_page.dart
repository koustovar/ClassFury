import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
import 'package:classfury/features/notices/presentation/bloc/notices_cubit.dart';
import 'package:classfury/features/notices/presentation/bloc/notices_state.dart';
import 'package:classfury/features/notices/data/repositories/notices_repository_impl.dart';

class CreateNoticePage extends StatefulWidget {
  const CreateNoticePage({super.key});

  @override
  State<CreateNoticePage> createState() => _CreateNoticePageState();
}

class _CreateNoticePageState extends State<CreateNoticePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _selectedBatchId;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onCreate(BuildContext context) {
    if (_formKey.currentState!.validate() && _selectedBatchId != null) {
      final authState = context.read<AuthBloc>().state;
      final teacherId = authState is AuthAuthenticated ? authState.user.uid : '';
      
      // Look up the batch name from the loaded batches
      final batchesState = context.read<BatchesCubit>().state;
      String batchName = 'General';
      if (batchesState is BatchesLoaded) {
        final batch = batchesState.batches.firstWhere(
          (b) => b.id == _selectedBatchId,
          orElse: () => batchesState.batches.first,
        );
        batchName = batch.name;
      }

      context.read<NoticesCubit>().createNotice(
        batchId: _selectedBatchId!,
        batchName: batchName,
        teacherId: teacherId,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
      );
    } else if (_selectedBatchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a batch')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final teacherId = authState is AuthAuthenticated ? authState.user.uid : '';

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => NoticesCubit(getIt<NoticesRepository>())),
        BlocProvider(create: (context) => BatchesCubit(getIt<BatchesRepository>())..loadBatches(teacherId)),
      ],
      child: Builder(
        builder: (context) {
          return BlocListener<NoticesCubit, NoticesState>(
            listener: (context, state) {
              if (state is NoticeCreated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notice sent successfully!')),
                );
                context.pop(true);
              } else if (state is NoticesError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
                );
              }
            },
            child: BlocBuilder<NoticesCubit, NoticesState>(
              builder: (context, state) {
                return LoadingOverlay(
                  isLoading: state is NoticesLoading,
                  child: Scaffold(
                    appBar: AppBar(
                      title: const Text('New Announcement'),
                    ),
                    body: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Select Batch', style: AppTypography.labelLarge),
                            const SizedBox(height: 12),
                            BlocBuilder<BatchesCubit, BatchesState>(
                              builder: (context, batchState) {
                                if (batchState is BatchesLoaded) {
                                  return DropdownButtonFormField<String>(
                                    value: _selectedBatchId,
                                    hint: const Text('Choose a batch'),
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    ),
                                    items: batchState.batches.map((batch) {
                                      return DropdownMenuItem(
                                        value: batch.id,
                                        child: Text(batch.name),
                                      );
                                    }).toList(),
                                    onChanged: (value) => setState(() => _selectedBatchId = value),
                                    validator: (v) => v == null ? 'Please select a batch' : null,
                                  );
                                }
                                return const Center(child: CircularProgressIndicator());
                              },
                            ),
                            const SizedBox(height: 24),
                            CustomTextField(
                              label: 'Notice Title',
                              hint: 'e.g. Exam Schedule Updated',
                              controller: _titleController,
                              validator: (v) => AppValidators.validateRequired(v, 'Title'),
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              label: 'Content',
                              hint: 'Enter the message for your students...',
                              controller: _contentController,
                              maxLines: 6,
                              validator: (v) => AppValidators.validateRequired(v, 'Content'),
                            ),
                            const SizedBox(height: 32),
                            CustomButton(
                              label: 'Publish Notice',
                              onPressed: () => _onCreate(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
      ),
    );
  }
}
