import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:classfury/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:classfury/app/theme/app_colors.dart';
import 'package:classfury/app/theme/app_typography.dart';
import 'package:classfury/core/widgets/custom_button.dart';
import 'package:classfury/core/widgets/custom_text_field.dart';
import 'package:classfury/core/widgets/loading_overlay.dart';
import 'package:classfury/core/utils/validators.dart';
import 'package:classfury/app/router/app_router.dart';
import 'package:classfury/features/auth/domain/entities/user_entity.dart';
import 'package:dio/dio.dart';
import 'package:classfury/core/constants/firebase_constants.dart';
import 'dart:convert';

class TeacherDetailsPage extends StatefulWidget {
  const TeacherDetailsPage({super.key});

  @override
  State<TeacherDetailsPage> createState() => _TeacherDetailsPageState();
}

class _TeacherDetailsPageState extends State<TeacherDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _subjectController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedTuitionType;
  File? _profileImage;
  bool _isUploading = false;

  final List<String> _tuitionTypes = ['Batch', 'Home Tuition', 'Both'];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _subjectController.dispose();
    _qualificationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImageToImageKit(File image) async {
    setState(() => _isUploading = true);

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(image.path,
            filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg'),
        'fileName': 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        'folder': '/teacher-profiles',
        'useUniqueFileName': 'true',
      });

      final basicAuth =
          'Basic ${base64Encode(utf8.encode('${FirebaseConstants.imageKitPrivateKey}:'))}';

      final response = await Dio().post(
        FirebaseConstants.imageKitUploadEndpoint,
        data: formData,
        options: Options(
          headers: {
            'Authorization': basicAuth,
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['url'];
      } else {
        throw Exception('Upload failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Image upload failed: $e'),
            backgroundColor: AppColors.error),
      );
      return null;
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _onSubmit() async {
    if (_formKey.currentState!.validate() &&
        _selectedTuitionType != null &&
        _profileImage != null) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthTeacherNeedsDetails) {
        String? profileUrl;
        if (_profileImage != null) {
          profileUrl = await _uploadImageToImageKit(_profileImage!);
          if (profileUrl == null) return; // Upload failed
        }

        context.read<AuthBloc>().add(SaveTeacherDetailsRequested(
              uid: authState.user.uid,
              name: _nameController.text.trim(),
              phoneNumber: _phoneController.text.trim(),
              subject: _subjectController.text.trim(),
              qualification: _qualificationController.text.trim(),
              tuitionType: _selectedTuitionType!,
              description: _descriptionController.text.trim(),
              profilePictureUrl: profileUrl!,
            ));
      }
    } else if (_profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a profile picture'),
            backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Teacher Details',
          style: AppTypography.headline6.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: BlocListener<AuthBloc, dynamic>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            appRouter.go('/teacher/dashboard');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error),
            );
          }
        },
        child: BlocBuilder<AuthBloc, dynamic>(
          builder: (context, state) {
            final isLoading = state is AuthLoading || _isUploading;

            return LoadingOverlay(
              isLoading: isLoading,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Please provide your details to complete your profile',
                        style: AppTypography.bodyText1,
                      ),
                      const Gap(24),
                      // Profile Picture Upload
                      Center(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: AppColors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(60),
                                  border: Border.all(
                                      color: AppColors.primary, width: 2),
                                ),
                                child: _profileImage != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(60),
                                        child: Image.file(_profileImage!,
                                            fit: BoxFit.cover),
                                      )
                                    : const Icon(Icons.camera_alt,
                                        size: 40, color: AppColors.primary),
                              ),
                            ),
                            const Gap(8),
                            Text(
                              'Tap to upload profile picture',
                              style: AppTypography.bodyText2
                                  .copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                      const Gap(24),
                      CustomTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        validator: (v) =>
                            AppValidators.validateRequired(v, 'Full Name'),
                      ),
                      const Gap(16),
                      CustomTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        keyboardType: TextInputType.phone,
                        validator: (v) =>
                            AppValidators.validateRequired(v, 'Phone Number'),
                      ),
                      const Gap(16),
                      CustomTextField(
                        controller: _subjectController,
                        label: 'Subject',
                        validator: (v) =>
                            AppValidators.validateRequired(v, 'Subject'),
                      ),
                      const Gap(16),
                      CustomTextField(
                        controller: _qualificationController,
                        label: 'Qualification',
                        validator: (v) =>
                            AppValidators.validateRequired(v, 'Qualification'),
                      ),
                      const Gap(16),
                      DropdownButtonFormField<String>(
                        value: _selectedTuitionType,
                        decoration: const InputDecoration(
                          labelText: 'Tuition Type',
                          border: OutlineInputBorder(),
                        ),
                        items: _tuitionTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTuitionType = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select tuition type';
                          }
                          return null;
                        },
                      ),
                      const Gap(16),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Brief Description',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        validator: (v) => AppValidators.validateRequired(
                            v, 'Brief Description'),
                      ),
                      const Gap(24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: Text(
                          'You may be called by us to verify your qualification.',
                          style: AppTypography.bodyText2.copyWith(
                            color: AppColors.primary,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Gap(32),
                      CustomButton(
                        label: 'Save Details',
                        onPressed: _onSubmit,
                      ),
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
}
