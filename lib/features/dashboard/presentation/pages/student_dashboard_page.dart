import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:classfury/app/theme/app_colors.dart';
import 'package:classfury/app/theme/app_typography.dart';
import 'package:classfury/core/widgets/custom_button.dart';
import 'package:classfury/core/widgets/error_widget.dart';
import 'package:classfury/core/di/injection.dart';
import 'package:classfury/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:classfury/features/batches/presentation/bloc/batches_cubit.dart';
import 'package:classfury/features/batches/presentation/bloc/batches_state.dart';
import 'package:classfury/features/batches/presentation/bloc/batch_requests_cubit.dart';
import 'package:classfury/features/batches/presentation/bloc/batch_requests_state.dart';
import 'package:classfury/features/batches/data/repositories/batches_repository_impl.dart';

class StudentDashboardPage extends StatelessWidget {
  const StudentDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = getIt<AuthBloc>().state;
    final studentId = authState is AuthAuthenticated ? authState.user.uid : '';

    if (studentId.isNotEmpty) {
      getIt<BatchRequestsCubit>().watchBatchRequests(studentId: studentId);
    }

    return Scaffold(
        drawer: const Drawer(), // Placeholder for student profile/settings
        appBar: AppBar(
          title: const Text('Student Portal'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.read<AuthBloc>().add(const SignOutRequested());
                        },
                        child: const Text('Logout', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<BatchesCubit, BatchesState>(
                bloc: getIt<BatchesCubit>(),
                builder: (builderContext, state) {
                  if (state is BatchesLoading) {
                    return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
                  } else if (state is BatchesError) {
                    return AppErrorWidget(
                      message: state.message,
                      onRetry: () => getIt<BatchesCubit>().loadStudentBatches(studentId),
                    );
                  } else if (state is BatchesLoaded) {
                    if (state.batches.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Padding(
                           padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                           child: Text('My Batches', style: AppTypography.h3),
                         ),
                         _buildBatchList(context, state.batches),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              BlocBuilder<BatchRequestsCubit, BatchRequestsState>(
                bloc: getIt<BatchRequestsCubit>(),
                builder: (context, state) {
                  if (state is BatchRequestsLoaded && state.requests.isNotEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                          child: Text('Pending Requests', style: AppTypography.h3),
                        ),
                        _buildRequestsList(context, state.requests),
                      ],
                    );
                  }
                  
                  // Show empty state only if NO batches AND NO requests
                  final batchesState = getIt<BatchesCubit>().state;
                  if (batchesState is BatchesLoaded && batchesState.batches.isEmpty && 
                      (state is! BatchRequestsLoaded || state.requests.isEmpty)) {
                    return _buildEmptyState(context);
                  }
                  
                  return const SizedBox.shrink();
                },
              ),
              const Gap(100), // Space for FAB
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final result = await context.push('/student/join');
            if (result == true) {
              if (context.mounted) {
                getIt<BatchesCubit>().loadStudentBatches(studentId);
              }
            }
          },
          label: const Text('Join Batch'),
          icon: const Icon(Icons.add),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 80, color: Theme.of(context).hintColor),
            const Gap(24),
            Text('No Classes Yet', style: Theme.of(context).textTheme.displaySmall),
            const Gap(12),
            Text(
              'You haven\'t joined any batches. Use a join code from your teacher to get started.',
              style: AppTypography.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const Gap(32),
            CustomButton(label: 'Join Now', onPressed: () => context.push('/student/join'), isFullWidth: false),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchList(BuildContext context, List batches) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: batches.length,
      separatorBuilder: (_, __) => const Gap(16),
      itemBuilder: (context, index) {
        final batch = batches[index];
        final color = Color(int.parse(batch.color.replaceFirst('#', '0xFF')));
        
        return InkWell(
          onTap: () => context.push('/student/batch-detail', extra: batch),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerTheme.color ?? AppColors.divider),
            ),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.class_, color: color, size: 20),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(batch.name, style: AppTypography.title),
                      Text(batch.subject, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Theme.of(context).hintColor),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequestsList(BuildContext context, List requests) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: requests.length,
      separatorBuilder: (_, __) => const Gap(12),
      itemBuilder: (context, index) {
        final request = requests[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.hourglass_empty_rounded, color: Colors.orange, size: 20),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.batchName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Text('Waiting for teacher approval', style: TextStyle(fontSize: 12, color: Colors.orange)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
