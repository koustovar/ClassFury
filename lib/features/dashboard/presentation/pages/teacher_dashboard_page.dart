import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:classfury/app/theme/app_colors.dart';
import 'package:classfury/app/theme/app_typography.dart';
import 'package:classfury/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:classfury/core/di/injection.dart';
import 'package:classfury/features/batches/data/repositories/batches_repository_impl.dart';
import 'package:classfury/features/exams/data/repositories/exams_repository_impl.dart';
import 'package:classfury/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:classfury/features/dashboard/presentation/bloc/dashboard_state.dart';

class TeacherDashboardPage extends StatelessWidget {
  const TeacherDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Standardize AuthBloc access
    final authState = context.read<AuthBloc>().state;
    final teacherId = authState is AuthAuthenticated ? authState.user.uid : '';

    return BlocProvider(
      create: (context) => DashboardCubit(
        getIt<BatchesRepository>(),
        getIt<ExamsRepository>(),
      )..loadDashboardData(teacherId),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const _StatsRow(),
                  const Gap(24),
                  const _PremiumBanner(),
                  const Gap(24),
                  const _QuickActionsGrid(),
                  const Gap(24),
                  _buildSectionHeader(context, 'Upcoming Classes',
                      () => context.push('/batches')),
                  const Gap(12),
                  const _PlaceholderCard(
                      title: 'No classes scheduled for today',
                      icon: Icons.video_camera_front_outlined),
                  const Gap(24),
                  _buildSectionHeader(context, 'Recent Notices', () {}),
                  const Gap(12),
                  const _PlaceholderCard(
                      title: 'No recent notices',
                      icon: Icons.campaign_outlined),
                  const Gap(40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      icon: const Icon(Icons.logout, color: AppColors.error),
                      label: const Text('Logout',
                          style: TextStyle(color: AppColors.error)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const Gap(40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final name =
                state is AuthAuthenticated ? state.user.name : 'Teacher';
            return Text(
              'Hello, $name 👋',
              style: AppTypography.h3.copyWith(color: Colors.white),
            );
          },
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon:
              const Icon(Icons.notifications_none_rounded, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () => context.push('/settings'),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const Spacer(),
        TextButton(
          onPressed: onSeeAll,
          child: Text('See All',
              style: AppTypography.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
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
  }
}

class _PremiumBanner extends StatelessWidget {
  const _PremiumBanner();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated && !state.user.isPremium) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: () => context.push('/premium'),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, size: 32, color: Colors.amber),
                    const Gap(16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Upgrade to Premium',
                              style: AppTypography.title.copyWith(
                                fontWeight: FontWeight.bold,
                              )),
                          const Gap(4),
                          Text('Get advanced tools and priority support.',
                              style: AppTypography.bodyMedium.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              )),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        return Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Batches',
                value: '${state.totalBatches}',
                icon: Icons.groups_rounded,
                color: AppColors.blue,
                onTap: () => context.push('/batches'),
              ),
            ),
            const Gap(12),
            Expanded(
                child: _StatCard(
                    label: 'Students',
                    value: '${state.totalStudents}',
                    icon: Icons.school_rounded,
                    color: AppColors.green)),
            const Gap(12),
            Expanded(
                child: _StatCard(
                    label: 'Exams',
                    value: '${state.totalExams}',
                    icon: Icons.quiz_rounded,
                    color: AppColors.orange)),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: Theme.of(context).dividerTheme.color ?? AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const Gap(12),
            Text(value, style: Theme.of(context).textTheme.displaySmall),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    final List<_QuickAction> actions = [
      _QuickAction('New Notice', Icons.campaign_rounded, AppColors.teal),
      _QuickAction('Create Exam', Icons.edit_note_rounded, AppColors.purple),
      _QuickAction('Schedule Class', Icons.video_call_rounded, AppColors.blue),
      _QuickAction('Attendance', Icons.how_to_reg_rounded, AppColors.green),
      _QuickAction('Add Material', Icons.upload_file_rounded, AppColors.orange),
      _QuickAction('Assignment', Icons.assignment_rounded, AppColors.red),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
        const Gap(16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) =>
              _QuickActionCard(action: actions[index]),
        ),
      ],
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  _QuickAction(this.label, this.icon, this.color);
}

class _QuickActionCard extends StatelessWidget {
  final _QuickAction action;
  const _QuickActionCard({required this.action});

  void _handleAction(BuildContext context) {
    switch (action.label) {
      case 'Create Batch':
        context.push('/batches/create');
        break;
      case 'New Notice':
        context.push('/notices/create');
        break;
      case 'Schedule Exam':
        context.push('/exams/create');
        break;
      case 'Take Attendance':
        context.push('/attendance/take');
        break;
      case 'Online Class':
        context.push('/classes/schedule');
        break;
      case 'Progress':
        context.push('/progress');
        break;
      case 'Materials':
        context.push('/materials/upload');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _handleAction(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: Theme.of(context).dividerTheme.color ?? AppColors.divider),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: action.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(action.icon, color: action.color, size: 28),
            ),
            const Gap(12),
            Text(
              action.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderCard extends StatelessWidget {
  final String title;
  final IconData icon;
  const _PlaceholderCard({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Theme.of(context).dividerTheme.color ?? AppColors.divider,
            style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).hintColor, size: 40),
          const Gap(12),
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).hintColor)),
        ],
      ),
    );
  }
}
