import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:classfury/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:classfury/features/exams/data/models/exam_model.dart';
import 'package:classfury/features/exams/presentation/bloc/exams_cubit.dart';
import 'package:classfury/features/exams/data/repositories/exams_repository_impl.dart';
import 'package:classfury/core/di/injection.dart';

enum UploadStatus { pending, uploading, success, failed }

class ExamPageData {
  final String id;
  File file;
  UploadStatus status;
  String? url;
  int retryCount;
  bool isBlurryWarningShown;

  ExamPageData(this.file)
      : id = const Uuid().v4(),
        status = UploadStatus.pending,
        retryCount = 0,
        isBlurryWarningShown = false;
}

class ExamCameraPage extends StatefulWidget {
  final ExamModel exam;
  const ExamCameraPage({super.key, required this.exam});

  @override
  State<ExamCameraPage> createState() => _ExamCameraPageState();
}

class _ExamCameraPageState extends State<ExamCameraPage> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  List<ExamPageData> _pages = [];
  bool _isUploadingQueue = false;
  bool _isCameraReady = false;
  int _currentView = 0; // 0 = Camera, 1 = Review

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _cameraController = CameraController(_cameras![0], ResolutionPreset.high,
          enableAudio: false);
      await _cameraController!.initialize();
      if (mounted) setState(() => _isCameraReady = true);
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  // Basic image sharpness check stub
  Future<bool> _isImageBlurry(File file) async {
    // A proper OpenCV implementation would be used here.
    // For now, simulating a random blur detection (10% chance) for demonstration.
    await Future.delayed(const Duration(milliseconds: 300));
    return (DateTime.now().millisecond % 10) == 0;
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;
    try {
      final XFile picture = await _cameraController!.takePicture();
      final File file = File(picture.path);

      final isBlurry = await _isImageBlurry(file);
      if (isBlurry) {
        if (!mounted) return;
        final bool? useAnyway = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Blur Warning'),
            content: const Text(
                'The image appears to be blurry. Do you want to retake it?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(c, true),
                  child: const Text('Use Anyway')),
              ElevatedButton(
                  onPressed: () => Navigator.pop(c, false),
                  child: const Text('Retake')),
            ],
          ),
        );
        if (useAnyway == null || !useAnyway) return;
      }

      setState(() {
        _pages.add(ExamPageData(file));
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to take picture.')));
    }
  }

  void _processUploadQueue() async {
    if (_isUploadingQueue) return;
    setState(() => _isUploadingQueue = true);

    final repository = getIt<ExamsRepository>();

    for (var page in _pages) {
      if (page.status == UploadStatus.success || page.retryCount >= 3) continue;

      setState(() => page.status = UploadStatus.uploading);

      try {
        final result =
            await repository.uploadExamFile(widget.exam.id, page.file);
        result.fold((failure) {
          setState(() {
            page.status = UploadStatus.failed;
            page.retryCount++;
          });
        }, (url) {
          setState(() {
            page.status = UploadStatus.success;
            page.url = url;
          });
        });
      } catch (e) {
        setState(() {
          page.status = UploadStatus.failed;
          page.retryCount++;
        });
      }
    }

    setState(() => _isUploadingQueue = false);
    _checkFinalSubmission();
  }

  void _checkFinalSubmission() {
    if (_pages.isEmpty) return;

    bool allSuccess = _pages.every((p) => p.status == UploadStatus.success);
    if (allSuccess) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        final submission = {
          'id': const Uuid().v4(),
          'examId': widget.exam.id,
          'studentId': authState.user.uid,
          'pages': _pages
              .asMap()
              .entries
              .map((e) => {
                    'pageNumber': e.key + 1,
                    'url': e.value.url,
                  })
              .toList(),
          'submittedAt': FieldValue.serverTimestamp(),
          'isLate': DateTime.now().isAfter(widget.exam.startTime
              .add(Duration(minutes: widget.exam.durationMinutes))),
        };
        getIt<ExamsCubit>().submitAnswer(submission);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Submission completed successfully'),
            backgroundColor: Colors.green));
        context.pop();
        context.pop(); // Go back past the exam screen
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentView == 0) {
      return _buildCameraView();
    } else {
      return _buildReviewView();
    }
  }

  Widget _buildCameraView() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Page ${_pages.length + 1}'),
        actions: [
          if (_pages.isNotEmpty)
            TextButton.icon(
              onPressed: () => setState(() => _currentView = 1),
              icon: const Icon(Icons.check, color: Colors.white),
              label:
                  const Text('Review', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isCameraReady
                  ? CameraPreview(_cameraController!)
                  : const Center(child: CircularProgressIndicator()),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    onPressed: _takePicture,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.camera_alt, color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Answers'),
        leading: BackButton(onPressed: () => setState(() => _currentView = 0)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pages.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) newIndex -= 1;
                  final item = _pages.removeAt(oldIndex);
                  _pages.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final page = _pages[index];
                return Card(
                  key: ValueKey(page.id),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Image.file(page.file,
                        width: 50, height: 50, fit: BoxFit.cover),
                    title: Text('Page ${index + 1}'),
                    subtitle: Row(
                      children: [
                        if (page.status == UploadStatus.success) ...[
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 16),
                          const Gap(4),
                          const Text('Uploaded',
                              style: TextStyle(color: Colors.green)),
                        ] else if (page.status == UploadStatus.uploading) ...[
                          const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2)),
                          const Gap(4),
                          const Text('Uploading...'),
                        ] else if (page.status == UploadStatus.failed) ...[
                          const Icon(Icons.error, color: Colors.red, size: 16),
                          const Gap(4),
                          const Text('Failed',
                              style: TextStyle(color: Colors.red)),
                        ] else ...[
                          const Icon(Icons.pending,
                              color: Colors.grey, size: 16),
                          const Gap(4),
                          const Text('Pending',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (page.status == UploadStatus.failed)
                          IconButton(
                            icon: const Icon(Icons.refresh, color: Colors.blue),
                            onPressed: () {
                              page.retryCount = 0;
                              _processUploadQueue();
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              setState(() => _pages.removeAt(index)),
                        ),
                        const Icon(Icons.drag_handle),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5))
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _currentView = 0),
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Add More'),
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pages.isEmpty || _isUploadingQueue
                        ? null
                        : _processUploadQueue,
                    icon: const Icon(Icons.cloud_upload),
                    label:
                        Text(_isUploadingQueue ? 'Uploading...' : 'Submit All'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
