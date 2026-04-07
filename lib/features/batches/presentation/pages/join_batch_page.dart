import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:classfury/app/theme/app_colors.dart';
import 'package:classfury/app/theme/app_typography.dart';
import 'package:classfury/core/widgets/custom_button.dart';
import 'package:classfury/core/widgets/custom_text_field.dart';
import 'package:classfury/core/widgets/loading_overlay.dart';
import 'package:classfury/core/di/injection.dart';
import 'package:classfury/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:classfury/features/batches/presentation/bloc/batches_cubit.dart';
import 'package:classfury/features/batches/presentation/bloc/batches_state.dart';

class JoinBatchPage extends StatefulWidget {
  const JoinBatchPage({super.key});

  @override
  State<JoinBatchPage> createState() => _JoinBatchPageState();
}

class _JoinBatchPageState extends State<JoinBatchPage> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onJoin(BuildContext buildContext) {
    if (_formKey.currentState!.validate()) {
      final authState = getIt<AuthBloc>().state;
      String studentId = '';
      String studentName = '';

      if (authState is AuthAuthenticated) {
        studentId = authState.user.uid;
        studentName = authState.user.name;
      }

      getIt<BatchesCubit>().requestToJoinBatch(
        joinCode: _codeController.text.trim().toUpperCase(),
        studentId: studentId,
        studentName: studentName,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BatchesCubit, BatchesState>(
      bloc: getIt<BatchesCubit>(),
      listener: (context, state) {
        if (state is BatchRequestSent) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content:
                  Text('Join request sent! Waiting for teacher approval.')));
          // Reload student batches to ensure the UI reflects current state (though the new batch won't appear until approved)
          final authState = getIt<AuthBloc>().state;
          if (authState is AuthAuthenticated) {
            getIt<BatchesCubit>().loadStudentBatches(authState.user.uid);
          }
          context.pop(true);
        } else if (state is BatchesError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message), backgroundColor: AppColors.error));
        }
      },
      child: BlocBuilder<BatchesCubit, BatchesState>(
        bloc: getIt<BatchesCubit>(),
        builder: (builderContext, state) {
          return LoadingOverlay(
            isLoading: state is BatchesLoading,
            child: Scaffold(
              appBar: AppBar(title: const Text('Join a Batch')),
              body: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.vignette_outlined,
                          size: 80, color: AppColors.primary),
                      const Gap(24),
                      Text('Enter Batch Code', style: AppTypography.h2),
                      const Gap(12),
                      Text(
                        'Ask your teacher for the 6-character code to join their classroom.',
                        style: AppTypography.bodyMedium
                            .copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(40),
                      CustomTextField(
                        label: 'Batch Code',
                        controller: _codeController,
                        hint: 'e.g. AB1234',
                        textAlign: TextAlign.center,
                        style: AppTypography.h2.copyWith(letterSpacing: 4),
                        maxLength: 6,
                        validator: (v) =>
                            (v?.length ?? 0) < 6 ? 'Invalid code' : null,
                      ),
                      const Gap(32),
                      CustomButton(
                          label: 'Join Batch',
                          onPressed: () => _onJoin(builderContext)),
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
