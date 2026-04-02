import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gap/gap.dart';
import 'package:classfury/app/theme/app_colors.dart';
import 'package:classfury/app/theme/app_typography.dart';
import 'package:classfury/core/di/injection.dart';
import 'package:classfury/features/batches/data/repositories/batches_repository_impl.dart';
import 'package:classfury/features/batches/presentation/bloc/batches_cubit.dart';
import 'package:classfury/features/batches/presentation/bloc/batches_state.dart';
import 'package:classfury/features/analytics/presentation/bloc/progress_cubit.dart';
import 'package:classfury/features/analytics/presentation/bloc/progress_state.dart';
import 'package:classfury/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:classfury/features/auth/presentation/bloc/auth_bloc.dart';

class BatchProgressPage extends StatefulWidget {
  const BatchProgressPage({super.key});

  @override
  State<BatchProgressPage> createState() => _BatchProgressPageState();
}

class _BatchProgressPageState extends State<BatchProgressPage> {
  String? _selectedBatchId;

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final teacherId = authState is AuthAuthenticated ? authState.user.uid : '';

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ProgressCubit(getIt<AnalyticsRepository>())),
        BlocProvider(create: (context) => BatchesCubit(getIt<BatchesRepository>())..loadBatches(teacherId)),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Performance Analytics')),
        body: Column(
          children: [
            _buildBatchSelector(),
            const Divider(height: 1),
            Expanded(
              child: BlocBuilder<ProgressCubit, ProgressState>(
                builder: (context, state) {
                   if (_selectedBatchId == null) {
                     return const Center(child: Text('Please select a batch to view progress'));
                   }
                   if (state is ProgressLoading) {
                     return const Center(child: CircularProgressIndicator());
                   } else if (state is ProgressError) {
                     return Center(child: Text(state.message));
                   } else if (state is ProgressLoaded) {
                     return _buildCharts(state.analytics);
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

  Widget _buildBatchSelector() {
    return BlocBuilder<BatchesCubit, BatchesState>(
      builder: (context, state) {
        if (state is BatchesLoaded) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              value: _selectedBatchId,
              hint: const Text('Select Batch'),
              items: state.batches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
              onChanged: (v) {
                setState(() => _selectedBatchId = v);
                context.read<ProgressCubit>().loadBatchAnalytics(v!);
              },
            ),
          );
        }
        return const LinearProgressIndicator();
      },
    );
  }

  Widget _buildCharts(BatchAnalytics analytics) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildStatCard('Overall Attendance', '${analytics.averageAttendance.toStringAsFixed(1)}%', Icons.calendar_today, Colors.blue),
        const Gap(24),
        _buildChartContainer('Attendance Trend (Recent)', _buildAttendanceChart(analytics.attendanceTrend)),
        const Gap(32),
        _buildStatCard('Class Performance', '${analytics.averageExamScore}%', Icons.assignment_outlined, Colors.orange),
        const Gap(24),
        _buildChartContainer('Exam Results (Recent)', _buildExamChart(analytics.examTrend)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color.withValues(alpha: 0.1), child: Icon(icon, color: color)),
          const Gap(20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.labelLarge),
              Text(value, style: AppTypography.h2.copyWith(color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartContainer(String title, Widget chart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.title),
        const Gap(16),
        Container(
          height: 200,
          padding: const EdgeInsets.only(right: 20, top: 20, bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: chart,
        ),
      ],
    );
  }

  Widget _buildAttendanceChart(List<double> data) {
    if (data.isEmpty) return const Center(child: Text('Insufficient data'));
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: Colors.blue.withValues(alpha: 0.1)),
          ),
        ],
      ),
    );
  }

  Widget _buildExamChart(List<double> data) {
    if (data.isEmpty) return const Center(child: Text('Insufficient data'));
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value, color: Colors.orange, width: 16, borderRadius: BorderRadius.circular(4))])).toList(),
      ),
    );
  }
}
