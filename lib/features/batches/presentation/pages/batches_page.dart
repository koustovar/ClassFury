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
import 'package:classfury/features/batches/data/models/batch_model.dart';

class BatchesPage extends StatefulWidget {
  const BatchesPage({super.key});

  @override
  State<BatchesPage> createState() => _BatchesPageState();
}

class _BatchesPageState extends State<BatchesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authState = context.read<AuthBloc>().state;
        final teacherId =
            authState is AuthAuthenticated ? authState.user.uid : '';
        if (teacherId.isNotEmpty) {
          getIt<BatchesCubit>().loadBatches(teacherId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final teacherId = authState is AuthAuthenticated ? authState.user.uid : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Batches'),
      ),
      body: BlocBuilder<BatchesCubit, BatchesState>(
        bloc: getIt<BatchesCubit>(),
        builder: (builderContext, state) {
          if (state is BatchesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BatchesError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => getIt<BatchesCubit>().loadBatches(teacherId),
            );
          } else if (state is BatchesLoaded) {
            final batches = state.batches;

            if (batches.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () => getIt<BatchesCubit>().loadBatches(teacherId),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: batches.length,
                separatorBuilder: (_, __) => const Gap(16),
                itemBuilder: (itemContext, index) {
                  final batch = batches[index];
                  return _BatchCard(batch: batch);
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await context.push('/batches/create');
          if (result == true) {
            if (context.mounted) {
              final authState = context.read<AuthBloc>().state;
              final tId =
                  authState is AuthAuthenticated ? authState.user.uid : '';
              getIt<BatchesCubit>().loadBatches(tId);
            }
          }
        },
        label: const Text('Create Batch'),
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
            Icon(Icons.groups_outlined,
                size: 80, color: Theme.of(context).hintColor),
            const Gap(24),
            Text('No Batches Found',
                style: Theme.of(context).textTheme.displaySmall),
            const Gap(12),
            Text(
              'Create your first batch to start managing your students and classes.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const Gap(32),
            CustomButton(
              label: 'Create Batch Now',
              onPressed: () => context.push('/batches/create'),
              isFullWidth: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _BatchCard extends StatelessWidget {
  final BatchModel batch;
  const _BatchCard({required this.batch});

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(batch.color.replaceFirst('#', '0xFF')));

    return InkWell(
      onTap: () => context.push('/batches/detail', extra: batch),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: Theme.of(context).dividerTheme.color ?? AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap(20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(batch.name,
                      style: Theme.of(context).textTheme.titleLarge),
                  const Gap(4),
                  Text(batch.subject,
                      style: AppTypography.bodySmall
                          .copyWith(color: color, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(Icons.person_outline,
                        size: 16, color: Theme.of(context).hintColor),
                    const Gap(4),
                    Text('${batch.studentCount}',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                const Gap(8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    batch.joinCode,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                ),
              ],
            ),
            const Gap(8),
            Icon(Icons.chevron_right, color: Theme.of(context).hintColor),
          ],
        ),
      ),
    );
  }
}
