import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:classfury/core/di/injection.dart';
import 'package:classfury/app/theme/app_typography.dart';
import 'package:classfury/features/batches/data/models/batch_model.dart';
import 'package:classfury/features/batches/presentation/bloc/batch_requests_cubit.dart';
import 'package:classfury/features/batches/presentation/bloc/batch_requests_state.dart';

class BatchStudentsPage extends StatelessWidget {
  final BatchModel batch;
  const BatchStudentsPage({super.key, required this.batch});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
      ),
      body: batch.studentIds.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.groups_rounded,
                      size: 80,
                      color:
                          Theme.of(context).hintColor.withValues(alpha: 0.5)),
                  const Gap(16),
                  const Text('No students in this batch yet.'),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: batch.studentIds.length,
              separatorBuilder: (_, __) => const Gap(12),
              itemBuilder: (context, index) {
                final studentId = batch.studentIds[index];
                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text('Student ID: $studentId'),
                  subtitle: const Text('View Profile'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Navigate to student profile
                  },
                );
              },
            ),
    );
  }
}

class BatchRequestsPage extends StatefulWidget {
  final BatchModel batch;
  const BatchRequestsPage({super.key, required this.batch});

  @override
  State<BatchRequestsPage> createState() => _BatchRequestsPageState();
}

class _BatchRequestsPageState extends State<BatchRequestsPage> {
  @override
  void initState() {
    super.initState();
    getIt<BatchRequestsCubit>().watchBatchRequests(
        teacherId: widget.batch.teacherId, batchId: widget.batch.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BatchRequestsCubit, BatchRequestsState>(
      bloc: getIt<BatchRequestsCubit>(),
      listener: (context, state) {
        if (state is BatchRequestsError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Join Requests'),
          ),
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(BatchRequestsState state) {
    if (state is BatchRequestsLoading)
      return const Center(child: CircularProgressIndicator());

    if (state is BatchRequestsLoaded) {
      if (state.requests.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_add_alt_1_rounded,
                  size: 80, color: Colors.orange.withValues(alpha: 0.5)),
              const Gap(16),
              const Text('No pending requests.'),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: state.requests.length,
        separatorBuilder: (_, __) => const Gap(16),
        itemBuilder: (context, index) {
          final request = state.requests[index];
          return Card(
            child: ListTile(
              title: Text(request.studentName, style: AppTypography.title),
              subtitle: Text(
                  'ID: ${request.studentId}\nRequested on: ${request.createdAt.toString().split('.')[0]}'),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () => getIt<BatchRequestsCubit>()
                        .respondToJoinRequest(request.id, true),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => getIt<BatchRequestsCubit>()
                        .respondToJoinRequest(request.id, false),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
    return const SizedBox.shrink();
  }
}

class BatchFeesPage extends StatelessWidget {
  final BatchModel batch;
  const BatchFeesPage({super.key, required this.batch});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fees Management'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet_rounded,
                size: 80, color: Colors.redAccent.withValues(alpha: 0.5)),
            const Gap(16),
            const Text('Fee records will appear here.'),
          ],
        ),
      ),
    );
  }
}
