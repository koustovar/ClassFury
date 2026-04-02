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
import '../bloc/batches_cubit.dart';
import '../bloc/batches_state.dart';
import 'package:classfury/features/batches/data/repositories/batches_repository_impl.dart';

class CreateBatchPage extends StatefulWidget {
  const CreateBatchPage({super.key});

  @override
  State<CreateBatchPage> createState() => _CreateBatchPageState();
}

class _CreateBatchPageState extends State<CreateBatchPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedColor = '#2563EB';

  final List<String> _colors = [
    '#2563EB', // Blue
    '#7C3AED', // Violet
    '#0D9488', // Teal
    '#EA580C', // Orange
    '#16A34A', // Green
    '#DC2626', // Red
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onCreate(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final authState = getIt<AuthBloc>().state;
      final teacherId = authState is AuthAuthenticated ? authState.user.uid : '';
      
      getIt<BatchesCubit>().createBatch(
        teacherId: teacherId,
        name: _nameController.text.trim(),
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
        color: _selectedColor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BatchesCubit, BatchesState>(
      bloc: getIt<BatchesCubit>(),
      listener: (context, state) {
          if (state is BatchCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Batch created successfully!')),
            );
            final authState = getIt<AuthBloc>().state;
            if (authState is AuthAuthenticated) {
              getIt<BatchesCubit>().loadBatches(authState.user.uid);
            }
            context.pop(true);
          } else if (state is BatchesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Theme.of(context).colorScheme.error),
            );
          }
        },
        child: BlocBuilder<BatchesCubit, BatchesState>(
          bloc: getIt<BatchesCubit>(),
          builder: (context, state) {
            return LoadingOverlay(
              isLoading: state is BatchesLoading,
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('Create New Batch'),
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomTextField(
                          label: 'Batch Name',
                          hint: 'e.g. Grade 10 - Science',
                          controller: _nameController,
                          validator: (v) => AppValidators.validateRequired(v, 'Batch Name'),
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          label: 'Subject',
                          hint: 'e.g. Physics',
                          controller: _subjectController,
                          validator: (v) => AppValidators.validateRequired(v, 'Subject'),
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          label: 'Description',
                          hint: 'Enter batch description...',
                          controller: _descriptionController,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24),
                        Text('Theme Color', style: Theme.of(context).textTheme.labelLarge),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 50,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _colors.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final colorCode = _colors[index];
                              final color = Color(int.parse(colorCode.replaceFirst('#', '0xFF')));
                              final isSelected = _selectedColor == colorCode;
                              
                              return GestureDetector(
                                onTap: () => setState(() => _selectedColor = colorCode),
                                child: Container(
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                                    boxShadow: isSelected ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4))] : null,
                                  ),
                                  child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 48),
                        CustomButton(
                          label: 'Create Batch',
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
}
