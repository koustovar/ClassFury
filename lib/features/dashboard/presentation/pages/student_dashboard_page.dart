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
import 'package:classfury/features/auth/domain/entities/user_entity.dart';
import 'package:classfury/features/batches/presentation/bloc/batches_cubit.dart';
import 'package:classfury/features/batches/presentation/bloc/batches_state.dart';
import 'package:classfury/features/batches/presentation/bloc/batch_requests_cubit.dart';
import 'package:classfury/features/batches/presentation/bloc/batch_requests_state.dart';
import 'package:classfury/features/notices/presentation/bloc/notices_cubit.dart';
import 'package:classfury/features/notices/presentation/bloc/notices_state.dart';
import 'package:classfury/core/services/url_launcher_service.dart';
import 'package:intl/intl.dart';

class StudentDashboardPage extends StatefulWidget {
  const StudentDashboardPage({super.key});

  @override
  State<StudentDashboardPage> createState() => _StudentDashboardPageState();
}

class _StudentDashboardPageState extends State<StudentDashboardPage> {
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    // Standardized use of AuthBloc from getIt to avoid context issues during init
    final authState = getIt<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final studentId = authState.user.uid;
      getIt<BatchesCubit>().loadStudentBatches(studentId);
      getIt<BatchRequestsCubit>().watchBatchRequests(studentId: studentId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      drawer: _buildDrawer(context, user),
      appBar: AppBar(
        title: const Text('Student Portal'),
        actions: [
          IconButton(
            icon: BlocBuilder<NoticesCubit, NoticesState>(
              bloc: getIt<NoticesCubit>(),
              builder: (context, state) {
                int count = 0;
                if (state is NoticesLoaded) {
                  count = state.notices.length;
                }
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_outlined),
                    if (count > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            count > 9 ? '9+' : '$count',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            onPressed: () {
              _showNotificationsBottomSheet(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _fetchData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocConsumer<BatchesCubit, BatchesState>(
                bloc: getIt<BatchesCubit>(),
                listener: (context, state) {
                  if (state is BatchesLoaded) {
                    final batchIds = state.batches.map((b) => b.id).toList();
                    getIt<NoticesCubit>().watchStudentNotices(batchIds);
                  }
                },
                builder: (builderContext, state) {
                  if (state is BatchesLoading) {
                    return const Center(
                        child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator()));
                  } else if (state is BatchesError) {
                    return AppErrorWidget(
                      message: state.message,
                      onRetry: _fetchData,
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
                          child: Text('My Batches',
                              style: AppTypography.h3.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              )),
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
                  if (state is BatchRequestsLoaded &&
                      state.requests.isNotEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                          child: Text('Pending Requests',
                              style: AppTypography.h3.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              )),
                        ),
                        _buildRequestsList(context, state.requests),
                      ],
                    );
                  }

                  final batchesState = getIt<BatchesCubit>().state;
                  if (batchesState is BatchesLoaded &&
                      batchesState.batches.isEmpty &&
                      (state is! BatchRequestsLoaded ||
                          state.requests.isEmpty)) {
                    return _buildEmptyState(context);
                  }

                  return const SizedBox.shrink();
                },
              ),
              const Gap(100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await context.push('/student/join');
          if (result == true) {
            if (context.mounted) {
              _fetchData();
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

  Widget _buildDrawer(BuildContext context, UserEntity? user) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.name ?? 'Student',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(user?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage:
                  user?.photoUrl != null && user!.photoUrl.isNotEmpty
                      ? NetworkImage(user.photoUrl)
                      : null,
              child: user?.photoUrl == null || user!.photoUrl.isEmpty
                  ? Icon(Icons.person,
                      size: 40, color: Theme.of(context).colorScheme.primary)
                  : null,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.group_add_outlined),
            title: const Text('Join New Batch'),
            onTap: () {
              Navigator.pop(context);
              context.push('/student/join');
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_none_outlined),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.pop(context);
              _showNotificationsBottomSheet(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              context.push('/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline_rounded),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
              getIt<UrlLauncherService>().openHelpAndSupport();
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
          ),
          const Gap(20),
        ],
      ),
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined,
                size: 80, color: Theme.of(context).hintColor),
            const Gap(24),
            Text('No Classes Yet',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    )),
            const Gap(12),
            Text(
              'You haven\'t joined any batches. Use a join code from your teacher to get started.',
              style: AppTypography.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const Gap(32),
            CustomButton(
                label: 'Join Now',
                onPressed: () => context.push('/student/join'),
                isFullWidth: false),
            const Gap(12),
            TextButton.icon(
              onPressed: _fetchData,
              icon: const Icon(Icons.refresh),
              label: const Text('Reload'),
            ),
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
              border: Border.all(
                  color: Theme.of(context).dividerTheme.color ??
                      AppColors.divider),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.class_, color: color, size: 20),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(batch.name,
                          style: AppTypography.title.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          )),
                      Text(batch.subject,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: color)),
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
              const Icon(Icons.hourglass_empty_rounded,
                  color: Colors.orange, size: 20),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.batchName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        )),
                    const Text('Waiting for teacher approval',
                        style: TextStyle(fontSize: 12, color: Colors.orange)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNotificationsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.notifications_rounded,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  const Gap(16),
                  Text('Recent Notices',
                      style: AppTypography.h3.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      )),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: BlocBuilder<NoticesCubit, NoticesState>(
                bloc: getIt<NoticesCubit>(),
                builder: (context, state) {
                  if (state is NoticesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is NoticesLoaded) {
                    if (state.notices.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_off_outlined,
                                size: 60, color: Theme.of(context).hintColor),
                            const Gap(16),
                            Text('No recent notices',
                                style: AppTypography.bodyLarge.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                )),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: state.notices.length,
                      separatorBuilder: (_, __) => const Gap(16),
                      itemBuilder: (context, index) {
                        final notice = state.notices[index];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Theme.of(context).dividerTheme.color ??
                                    AppColors.divider),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: Text(
                                          notice.title.length > 50
                                              ? '${notice.title.substring(0, 50)}...'
                                              : notice.title,
                                          style: AppTypography.title.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ))),
                                  const Gap(8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        DateFormat('dd MMM yyyy, hh:mm a')
                                            .format(notice.createdAt),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                      const Gap(4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          notice.batchName,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Gap(8),
                              Text(
                                  notice.content.length > 200
                                      ? '${notice.content.substring(0, 200)}...'
                                      : notice.content,
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  )),
                              if (notice.attachmentUrls.isNotEmpty) ...[
                                const Gap(12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: notice.attachmentUrls
                                      .map((url) => Chip(
                                            avatar: const Icon(Icons.attachment,
                                                size: 16),
                                            label: const Text('Attachment'),
                                            visualDensity:
                                                VisualDensity.compact,
                                          ))
                                      .toList(),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
