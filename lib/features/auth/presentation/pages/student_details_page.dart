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
import 'package:classfury/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:classfury/features/auth/domain/entities/user_entity.dart';

class StudentDetailsPage extends StatefulWidget {
  const StudentDetailsPage({super.key});

  @override
  State<StudentDetailsPage> createState() => _StudentDetailsPageState();
}

class _StudentDetailsPageState extends State<StudentDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _studentNameController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _studentPhoneController = TextEditingController();
  final _classController = TextEditingController();
  final _schoolNameController = TextEditingController();
  String? _selectedBoard;

  final List<String> _boards = ['WB', 'CBSE', 'ICSE', 'IB', 'State Board', 'Other'];

  @override
  void dispose() {
    _studentNameController.dispose();
    _guardianNameController.dispose();
    _studentPhoneController.dispose();
    _classController.dispose();
    _schoolNameController.dispose();
    super.dispose();
  }

class _StudentDetailsPageState extends State<StudentDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _studentNameController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _studentPhoneController = TextEditingController();
  final _classController = TextEditingController();
  final _schoolNameController = TextEditingController();
  String? _selectedBoard;

  final List<String> _boards = ['WB', 'CBSE', 'ICSE', 'IB', 'State Board', 'Other'];

  @override
  void dispose() {
    _studentNameController.dispose();
    _guardianNameController.dispose();
    _studentPhoneController.dispose();
    _classController.dispose();
    _schoolNameController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate() && _selectedBoard != null) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context.read<AuthBloc>().add(SaveStudentDetailsRequested(
          uid: authState.user.uid,
          studentName: _studentNameController.text.trim(),
          guardianName: _guardianNameController.text.trim(),
          studentPhone: _studentPhoneController.text.trim(),
          className: _classController.text.trim(),
          schoolName: _schoolNameController.text.trim(),
          board: _selectedBoard!,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          context.go('/student/dashboard');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const LoadingOverlay();
          }

          return Scaffold(
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
                  CustomTextField(
                    controller: _studentNameController,
                    labelText: 'Student Name',
                    validator: Validators.required,
                  ),
                  const Gap(16),
                  CustomTextField(
                    controller: _guardianNameController,
                    labelText: 'Guardian Name',
                    validator: Validators.required,
                  ),
                  const Gap(16),
                  CustomTextField(
                    controller: _studentPhoneController,
                    labelText: 'Student Phone Number',
                    keyboardType: TextInputType.phone,
                    validator: Validators.phone,
                  ),
                  const Gap(16),
                  CustomTextField(
                    controller: _classController,
                    labelText: 'Class',
                    validator: Validators.required,
                  ),
                  const Gap(16),
                  CustomTextField(
                    controller: _schoolNameController,
                    labelText: 'Current School Name',
                    validator: Validators.required,
                  ),
                  const Gap(16),
                  DropdownButtonFormField<String>(
                    value: _selectedBoard,
                    decoration: const InputDecoration(
                      labelText: 'Board',
                      border: OutlineInputBorder(),
                    ),
                    items: _boards.map((board) {
                      return DropdownMenuItem(
                        value: board,
                        child: Text(board),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBoard = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a board';
                      }
                      return null;
                    },
                  ),
                  const Gap(32),
                  CustomButton(
                    text: 'Save Details',
                    onPressed: _onSubmit,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}