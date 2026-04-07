import 'dart:io';
import 'package:flutter/material.dart' hide MaterialType;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:file_picker/file_picker.dart';
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
import 'package:classfury/features/materials/data/models/material_model.dart';
import 'package:classfury/features/materials/presentation/bloc/materials_cubit.dart';
import 'package:classfury/features/materials/presentation/bloc/materials_state.dart';
import 'package:classfury/features/materials/data/repositories/materials_repository_impl.dart';

class UploadMaterialPage extends StatefulWidget {
  final BatchModel? batch;
  const UploadMaterialPage({super.key, this.batch});

  @override
  State<UploadMaterialPage> createState() => _UploadMaterialPageState();
}

class _UploadMaterialPageState extends State<UploadMaterialPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String? _selectedBatchId;
  MaterialType _selectedType = MaterialType.notes;
  File? _selectedFile;
  String? _fileName;

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
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _fileName = result.files.single.name;
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

  void _onUpload(BuildContext uploadContext) {
    if (_formKey.currentState!.validate() &&
        _selectedBatchId != null &&
        _selectedFile != null) {
      final authState = getIt<AuthBloc>().state;
      final teacherId =
          authState is AuthAuthenticated ? authState.user.uid : '';

      final materialData = MaterialModel(
        id: '',
        batchId: _selectedBatchId!,
        teacherId: teacherId,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        fileUrl: '', // Will be set by datasource
        fileName: _fileName!,
        type: _selectedType,
        createdAt: DateTime.now(),
      );

      uploadContext.read<MaterialsCubit>().uploadMaterial(
            materialData: materialData,
            file: _selectedFile!,
          );
    } else if (_selectedFile == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please select a file')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final teacherId = authState is AuthAuthenticated ? authState.user.uid : '';

    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => MaterialsCubit(getIt<MaterialsRepository>())),
        BlocProvider(
            create: (context) => BatchesCubit(getIt<BatchesRepository>())
              ..loadBatches(teacherId)),
      ],
      child: Builder(
        builder: (builderContext) {
          return BlocListener<MaterialsCubit, MaterialsState>(
            bloc: builderContext.read<MaterialsCubit>(),
            listener: (context, state) {
              if (state is MaterialUploaded) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Material uploaded successfully!')));
                context.pop();
              } else if (state is MaterialsError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Upload failed: ${state.message}'),
                    backgroundColor: AppColors.error,
                    duration: const Duration(seconds: 10),
                    action: SnackBarAction(
                        label: 'OK', textColor: Colors.white, onPressed: () {}),
                  ),
                );
              }
            },
            child: BlocBuilder<MaterialsCubit, MaterialsState>(
              bloc: builderContext.read<MaterialsCubit>(),
              builder: (context, state) {
                return LoadingOverlay(
                  isLoading: state is MaterialsLoading,
                  child: Scaffold(
                    appBar: AppBar(title: const Text('Share Material')),
                    body: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildBatchSelector(),
                            const Gap(20),
                            _buildTypeSelector(),
                            const Gap(20),
                            CustomTextField(
                                label: 'Title',
                                hint: 'e.g. Lecture Notes - Unit 1',
                                controller: _titleController,
                                validator: (v) =>
                                    AppValidators.validateRequired(v, 'Title')),
                            const Gap(20),
                            CustomTextField(
                                label: 'Description',
                                hint: 'Briefly describe the content...',
                                controller: _descController,
                                maxLines: 3),
                            const Gap(32),
                            _buildFilePicker(),
                            const Gap(40),
                            CustomButton(
                                label: 'Upload & Share',
                                onPressed: () => _onUpload(builderContext)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
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
            items: state.batches
                .map((b) => DropdownMenuItem(value: b.id, child: Text(b.name)))
                .toList(),
            onChanged: (v) => setState(() => _selectedBatchId = v),
          );
        }
        return const Center(child: LinearProgressIndicator());
      },
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Material Type', style: AppTypography.labelLarge),
        const Gap(12),
        Wrap(
          spacing: 12,
          children: MaterialType.values.map((type) {
            final isSelected = _selectedType == type;
            return ChoiceChip(
              label: Text(type.name.toUpperCase()),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedType = type),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFilePicker() {
    return InkWell(
      onTap: _pickFile,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: AppColors.divider, style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            Icon(
                _selectedFile == null
                    ? Icons.cloud_upload_outlined
                    : Icons.insert_drive_file,
                size: 48,
                color: AppColors.primary),
            const Gap(16),
            Text(_fileName ?? 'Tap to select a file (PDF, Doc, Image)',
                style: AppTypography.bodySmall),
            if (_selectedFile != null) ...[
              const Gap(8),
              Text('Replace file',
                  style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          ],
        ),
      ),
    );
  }
}
