import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:classfury/app/theme/app_colors.dart';
import 'package:classfury/app/theme/app_typography.dart';
import 'package:classfury/core/di/injection.dart';
import 'package:classfury/features/batches/data/models/batch_model.dart';
import 'package:classfury/features/notices/presentation/bloc/notices_cubit.dart';
import 'package:classfury/features/notices/presentation/bloc/notices_state.dart';
import 'package:classfury/features/exams/presentation/bloc/exams_cubit.dart';
import 'package:classfury/features/exams/presentation/bloc/exams_state.dart';
import 'package:classfury/features/classes/presentation/bloc/classes_cubit.dart';
import 'package:classfury/features/classes/presentation/bloc/classes_state.dart';
import 'package:classfury/features/materials/presentation/bloc/materials_cubit.dart';
import 'package:classfury/features/materials/presentation/bloc/materials_state.dart';
import 'package:classfury/features/notices/data/repositories/notices_repository_impl.dart';
import 'package:classfury/features/exams/data/repositories/exams_repository_impl.dart';
import 'package:classfury/features/classes/data/repositories/classes_repository_impl.dart';
import 'package:classfury/features/materials/data/repositories/materials_repository_impl.dart';

class StudentBatchDetailPage extends StatefulWidget {
  final BatchModel batch;
  const StudentBatchDetailPage({super.key, required this.batch});

  @override
  State<StudentBatchDetailPage> createState() => _StudentBatchDetailPageState();
}

class _StudentBatchDetailPageState extends State<StudentBatchDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => NoticesCubit(getIt<NoticesRepository>())..loadBatchNotices(widget.batch.id)),
        BlocProvider(create: (context) => ExamsCubit(getIt<ExamsRepository>())..loadBatchExams(widget.batch.id)),
        BlocProvider(create: (context) => ClassesCubit(getIt<ClassesRepository>())..loadBatchClasses(widget.batch.id)),
        BlocProvider(create: (context) => MaterialsCubit(getIt<MaterialsRepository>())..loadBatchMaterials(widget.batch.id)),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.batch.name),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Notices'),
              Tab(text: 'Exams'),
              Tab(text: 'Classes'),
              Tab(text: 'Materials'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _NoticesTab(batchId: widget.batch.id),
            _ExamsTab(batchId: widget.batch.id),
            _ClassesTab(batchId: widget.batch.id),
            _MaterialsTab(batchId: widget.batch.id),
          ],
        ),
      ),
    );
  }
}

class _NoticesTab extends StatelessWidget {
  final String batchId;
  const _NoticesTab({required this.batchId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NoticesCubit, NoticesState>(
      builder: (context, state) {
        if (state is NoticesLoading) return const Center(child: CircularProgressIndicator());
        if (state is NoticesLoaded) {
          if (state.notices.isEmpty) return const Center(child: Text('No announcements yet'));
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: state.notices.length,
            separatorBuilder: (_, __) => const Gap(16),
            itemBuilder: (context, index) {
              final notice = state.notices[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(notice.title, style: AppTypography.title)),
                          Text(
                            DateFormat('dd MMM yyyy, hh:mm a').format(notice.createdAt),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
                          ),
                        ],
                      ),
                      const Gap(8),
                      Text(notice.content, style: AppTypography.bodyMedium),
                    ],
                  ),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _ExamsTab extends StatelessWidget {
  final String batchId;
  const _ExamsTab({required this.batchId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExamsCubit, ExamsState>(
      builder: (context, state) {
        if (state is ExamsLoading) return const Center(child: CircularProgressIndicator());
        if (state is ExamsLoaded) {
          if (state.exams.isEmpty) return const Center(child: Text('No upcoming exams'));
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: state.exams.length,
            separatorBuilder: (_, __) => const Gap(16),
            itemBuilder: (context, index) {
              final exam = state.exams[index];
              return ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.divider)),
                title: Text(exam.title),
                subtitle: Text('Status: ${exam.status.name.toUpperCase()}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                   context.push('/exams/student', extra: exam);
                },
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _ClassesTab extends StatelessWidget {
  final String batchId;
  const _ClassesTab({required this.batchId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClassesCubit, ClassesState>(
      builder: (context, state) {
        if (state is ClassesLoading) return const Center(child: CircularProgressIndicator());
        if (state is ClassesLoaded) {
           if (state.classes.isEmpty) return const Center(child: Text('No classes scheduled'));
           return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: state.classes.length,
            separatorBuilder: (_, __) => const Gap(16),
            itemBuilder: (context, index) {
              final cl = state.classes[index];
              return ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.divider)),
                title: Text(cl.title),
                subtitle: Text(cl.isLive ? 'LIVE NOW' : 'Scheduled'),
                trailing: IconButton(
                  icon: const Icon(Icons.video_call, color: Colors.green),
                  onPressed: () => launchUrl(Uri.parse(cl.meetingLink)),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _MaterialsTab extends StatelessWidget {
  final String batchId;
  const _MaterialsTab({required this.batchId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MaterialsCubit, MaterialsState>(
      builder: (context, state) {
        if (state is MaterialsLoading) return const Center(child: CircularProgressIndicator());
        if (state is MaterialsLoaded) {
          if (state.materials.isEmpty) return const Center(child: Text('No study materials shared'));
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: state.materials.length,
            separatorBuilder: (_, __) => const Gap(16),
            itemBuilder: (context, index) {
              final m = state.materials[index];
              return ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.divider)),
                leading: const Icon(Icons.insert_drive_file),
                title: Text(m.title),
                subtitle: Text(m.type.name.toUpperCase()),
                trailing: IconButton(
                   icon: const Icon(Icons.download),
                   onPressed: () => launchUrl(Uri.parse(m.fileUrl)),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
