import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:classfury/app/theme/app_colors.dart';
import 'package:classfury/app/theme/app_typography.dart';
import 'package:classfury/core/di/injection.dart';
import 'package:classfury/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:classfury/features/batches/presentation/bloc/batches_cubit.dart';
import 'package:classfury/features/batches/presentation/bloc/batch_requests_cubit.dart';
import 'package:classfury/features/batches/presentation/bloc/batch_requests_state.dart';
import 'package:classfury/features/batches/data/models/batch_model.dart';

class BatchBoardPage extends StatefulWidget {
  final BatchModel batch;
  const BatchBoardPage({super.key, required this.batch});

  @override
  State<BatchBoardPage> createState() => _BatchBoardPageState();
}

class _BatchBoardPageState extends State<BatchBoardPage> {
  @override
  void initState() {
    super.initState();
    getIt<BatchRequestsCubit>().watchBatchRequests(
      teacherId: widget.batch.teacherId, 
      batchId: widget.batch.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.batch.name),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteConfirmation(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    Gap(12),
                    Text('Delete Batch', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBatchHeader(context),
            const Gap(32),
            Text('Batch Management', style: Theme.of(context).textTheme.titleLarge),
            const Gap(16),
            _buildManagementGrid(context),
            const Gap(32),
            Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
            const Gap(16),
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchHeader(BuildContext context) {
    final color = Color(int.parse(widget.batch.color.replaceFirst('#', '0xFF')));
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.batch.subject,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                  ),
                  const Gap(4),
                  Text(
                    widget.batch.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.vpn_key_outlined, color: Colors.white, size: 16),
                    const Gap(8),
                    Text(
                      widget.batch.joinCode,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(24),
          Row(
            children: [
              _buildHeaderStat(context, '${widget.batch.studentCount}', 'Students'),
              const Gap(32),
              _buildHeaderStat(context, '0', 'Lectures'),
              const Gap(32),
              _buildHeaderStat(context, '0', 'Exams'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(BuildContext context, String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildManagementGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard(
          context,
          'Students',
          '${widget.batch.studentCount}',
          Icons.groups_rounded,
          AppColors.primary,
          () => context.push('/batches/students', extra: widget.batch),
        ),
        BlocBuilder<BatchRequestsCubit, BatchRequestsState>(
          bloc: getIt<BatchRequestsCubit>(),
          builder: (context, state) {
            final count = state is BatchRequestsLoaded ? state.requests.length : 0;
            return _buildStatCard(
              context,
              'Requests',
              '$count',
              Icons.person_add_rounded,
              Colors.orange,
              () => context.push('/batches/requests', extra: widget.batch),
              badge: count > 0 ? 'New' : null,
            );
          },
        ),
        _buildStatCard(
          context,
          'Pending Fees',
          '₹ 0',
          Icons.account_balance_wallet_rounded,
          Colors.redAccent,
          () => context.push('/batches/fees', extra: widget.batch),
        ),
        _buildStatCard(
          context,
          'Attendance',
          '92%',
          Icons.calendar_today_rounded,
          Colors.teal,
          () => context.push('/attendance/batch', extra: widget.batch),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    String? badge,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).dividerTheme.color ?? AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        _buildActionTile(
          context,
          'Send Zoom Link',
          'Share a meeting or Zoom link with text',
          Icons.link_rounded,
          Colors.blue,
          () => _showSendLinkDialog(context),
        ),
        const Gap(12),
        _buildActionTile(
          context,
          'Post Notification',
          'Send important updates to this batch',
          Icons.notifications_active_outlined,
          Colors.orange,
          () => context.push('/notices/create', extra: widget.batch),
        ),
        const Gap(12),
        _buildActionTile(
          context,
          'Upload PDF / Material',
          'Share notes, PDFs or assignments',
          Icons.picture_as_pdf_outlined,
          Colors.red,
          () => context.push('/materials/upload', extra: widget.batch),
        ),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String title,
    String subTitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.all(8),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subTitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).dividerTheme.color ?? AppColors.divider),
      ),
    );
  }

  void _showSendLinkDialog(BuildContext context) {
    final titleController = TextEditingController();
    final linkController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Meeting Link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g. Physics Extra Class'),
            ),
            const Gap(16),
            TextField(
              controller: linkController,
              decoration: const InputDecoration(labelText: 'Link', hintText: 'https://zoom.us/j/...'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement actual link sending via notice repository
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Link sent to students!')),
              );
            },
            child: const Text('Send Now'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Batch?'),
        content: const Text(
          'This will permanently delete this batch and all its data. Students will no longer be able to access it. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final authState = getIt<AuthBloc>().state;
              if (authState is AuthAuthenticated) {
                getIt<BatchesCubit>().deleteBatch(
                  batchId: widget.batch.id,
                  teacherId: authState.user.uid,
                );
                Navigator.pop(context); // Close dialog
                context.pop(); // Go back to batches list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Batch deleted successfully')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }
}
