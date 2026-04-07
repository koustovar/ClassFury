import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:classfury/app/theme/app_typography.dart';
import 'package:classfury/core/widgets/custom_button.dart';
import 'package:classfury/features/exams/data/models/exam_model.dart';

class StudentExamPage extends StatefulWidget {
  final ExamModel exam;
  const StudentExamPage({super.key, required this.exam});

  @override
  State<StudentExamPage> createState() => _StudentExamPageState();
}

class _StudentExamPageState extends State<StudentExamPage> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final startTime = widget.exam.startTime;
    final endTime = startTime.add(Duration(minutes: widget.exam.durationMinutes));
    final deadline = endTime.add(Duration(minutes: widget.exam.gracePeriodMinutes));
    
    final isBeforeExam = _now.isBefore(startTime);
    final isDuringExam = _now.isAfter(startTime) && _now.isBefore(endTime);
    final isInGracePeriod = _now.isAfter(endTime) && _now.isBefore(deadline);
    final isPastDeadline = _now.isAfter(deadline);

    return Scaffold(
      appBar: AppBar(title: Text(widget.exam.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Exam Details', style: AppTypography.title),
                    const Divider(),
                    Text('Start Time: ${DateFormat('dd MMM yyyy, hh:mm a').format(startTime)}'),
                    Text('Duration: ${widget.exam.durationMinutes} minutes'),
                    Text('Grace Period: ${widget.exam.gracePeriodMinutes} minutes'),
                    Text('Deadline: ${DateFormat('dd MMM yyyy, hh:mm a').format(deadline)}'),
                  ],
                ),
              ),
            ),
            const Gap(24),
            
            // State display
            if (isBeforeExam) ...[
              const Icon(Icons.timer_outlined, size: 64, color: Colors.blue),
              const Gap(16),
              Text('Exam Starts In', textAlign: TextAlign.center, style: AppTypography.h3),
              Text(
                _formatDuration(startTime.difference(_now)),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ] else if (isDuringExam) ...[
              const Icon(Icons.access_time_filled, size: 64, color: Colors.green),
              const Gap(16),
              Text('Time Remaining', textAlign: TextAlign.center, style: AppTypography.h3),
              Text(
                _formatDuration(endTime.difference(_now)),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const Gap(24),
              if (widget.exam.questionUrl != null)
                CustomButton(
                  label: 'View Question Paper',
                  onPressed: () => launchUrl(Uri.parse(widget.exam.questionUrl!)),
                )
              else
                const Text('No question paper uploaded.', textAlign: TextAlign.center),
            ] else if (isInGracePeriod) ...[
              const Icon(Icons.warning_amber_rounded, size: 64, color: Colors.orange),
              const Gap(16),
              Text('Exam Finished. Grace Period Active', textAlign: TextAlign.center, style: AppTypography.h3.copyWith(color: Colors.orange)),
              Text(
                'Closes in: ${_formatDuration(deadline.difference(_now))}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orange),
              ),
            ] else if (isPastDeadline) ...[
              const Icon(Icons.cancel_rounded, size: 64, color: Colors.red),
              const Gap(16),
              Text('Submission Closed', textAlign: TextAlign.center, style: AppTypography.h3.copyWith(color: Colors.red)),
            ],
            
            const Gap(32),

            if (isDuringExam || isInGracePeriod)
              CustomButton(
                label: 'Upload Answer Sheet',
                onPressed: () {
                  context.push('/exams/camera', extra: widget.exam);
                },
              ),
          ],
        ),
      ),
    );
  }
}
