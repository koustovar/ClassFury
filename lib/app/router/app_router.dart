import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:classfury/features/auth/presentation/pages/login_page.dart';
import 'package:classfury/features/auth/presentation/pages/signup_page.dart';
import 'package:classfury/features/auth/presentation/pages/student_details_page.dart';
import 'package:classfury/features/auth/presentation/pages/teacher_details_page.dart';
import 'package:classfury/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:classfury/features/dashboard/presentation/pages/teacher_dashboard_page.dart';
import 'package:classfury/features/dashboard/presentation/pages/student_dashboard_page.dart';
import 'package:classfury/features/dashboard/presentation/pages/settings_page.dart';
import 'package:classfury/features/dashboard/presentation/pages/premium_page.dart';
import 'package:classfury/features/batches/presentation/pages/batches_page.dart';
import 'package:classfury/features/batches/presentation/pages/create_batch_page.dart';
import 'package:classfury/features/batches/presentation/pages/batch_board_page.dart';
import 'package:classfury/features/batches/presentation/pages/batch_detail_subpages.dart';
import 'package:classfury/features/batches/presentation/pages/join_batch_page.dart';
import 'package:classfury/features/batches/presentation/pages/student_batch_detail_page.dart';
import 'package:classfury/features/batches/data/models/batch_model.dart';
import 'package:classfury/features/notices/presentation/pages/create_notice_page.dart';
import 'package:classfury/features/exams/presentation/pages/create_exam_page.dart';
import 'package:classfury/features/exams/presentation/pages/student_exam_page.dart';
import 'package:classfury/features/exams/presentation/pages/exam_camera_page.dart';
import 'package:classfury/features/exams/data/models/exam_model.dart';
import 'package:classfury/features/attendance/presentation/pages/take_attendance_page.dart';
import 'package:classfury/features/classes/presentation/pages/schedule_class_page.dart';
import 'package:classfury/features/analytics/presentation/pages/batch_progress_page.dart';
import 'package:classfury/features/materials/presentation/pages/upload_material_page.dart';
import 'package:classfury/features/materials/presentation/pages/batch_materials_page.dart';

final appRouter = GoRouter(
  initialLocation: '/auth/login',
  redirect: (context, state) {
    final authState = context.read<AuthBloc>().state;
    final isLoggedIn = authState is AuthAuthenticated;
    final isAuthPath = state.matchedLocation.startsWith('/auth');

    if (!isLoggedIn && !isAuthPath) {
      return '/auth/login';
    }
    if (isLoggedIn && isAuthPath) {
      return authState.user.role == 'teacher'
          ? '/teacher/dashboard'
          : '/student/dashboard';
    }
    return null;
  },
  routes: [
    // Auth Routes
    GoRoute(
      path: '/auth/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/auth/signup',
      builder: (context, state) => const SignUpPage(),
    ),

    // Student Routes
    GoRoute(
      path: '/student/dashboard',
      builder: (context, state) => const StudentDashboardPage(),
    ),
    GoRoute(
      path: '/student/details',
      builder: (context, state) => const StudentDetailsPage(),
    ),
    GoRoute(
      path: '/student/join',
      builder: (context, state) => const JoinBatchPage(),
    ),
    GoRoute(
      path: '/student/batch-detail',
      builder: (context, state) {
        final batch = state.extra as BatchModel?;
        if (batch == null) {
          return const StudentDashboardPage();
        }
        return StudentBatchDetailPage(batch: batch);
      },
    ),

    // Teacher Routes
    GoRoute(
      path: '/teacher/dashboard',
      builder: (context, state) => const TeacherDashboardPage(),
    ),
    GoRoute(
      path: '/teacher/details',
      builder: (context, state) => const TeacherDetailsPage(),
    ),

    // Batch Routes
    GoRoute(
      path: '/batches',
      builder: (context, state) => const BatchesPage(),
    ),
    GoRoute(
      path: '/batches/create',
      builder: (context, state) => const CreateBatchPage(),
    ),
    GoRoute(
      path: '/batches/detail',
      builder: (context, state) {
        final batch = state.extra as BatchModel?;
        if (batch == null) {
          return const BatchesPage();
        }
        return BatchBoardPage(batch: batch);
      },
    ),
    GoRoute(
      path: '/batches/students',
      builder: (context, state) {
        final batch = state.extra as BatchModel?;
        if (batch == null) {
          return const BatchesPage();
        }
        return BatchStudentsPage(batch: batch);
      },
    ),
    GoRoute(
      path: '/batches/requests',
      builder: (context, state) {
        final batch = state.extra as BatchModel?;
        if (batch == null) {
          return const BatchesPage();
        }
        return BatchRequestsPage(batch: batch);
      },
    ),
    GoRoute(
      path: '/batches/fees',
      builder: (context, state) {
        final batch = state.extra as BatchModel?;
        if (batch == null) {
          return const BatchesPage();
        }
        return BatchFeesPage(batch: batch);
      },
    ),

    // Notice Routes
    GoRoute(
      path: '/notices/create',
      builder: (context, state) => const CreateNoticePage(),
    ),

    // Exam Routes
    GoRoute(
      path: '/exams/create',
      builder: (context, state) => const CreateExamPage(),
    ),
    GoRoute(
      path: '/exams/student',
      builder: (context, state) {
        final exam = state.extra as ExamModel?;
        if (exam == null) {
          return const StudentDashboardPage();
        }
        return StudentExamPage(exam: exam);
      },
    ),
    GoRoute(
      path: '/exams/camera',
      builder: (context, state) {
        final exam = state.extra as ExamModel?;
        if (exam == null) {
          return const StudentDashboardPage();
        }
        return ExamCameraPage(exam: exam);
      },
    ),

    // Attendance Routes
    GoRoute(
      path: '/attendance/take',
      builder: (context, state) => const TakeAttendancePage(),
    ),

    // Class Routes
    GoRoute(
      path: '/classes/schedule',
      builder: (context, state) => const ScheduleClassPage(),
    ),

    // Progress Routes
    GoRoute(
      path: '/progress',
      builder: (context, state) => const BatchProgressPage(),
    ),

    // Material Routes
    GoRoute(
      path: '/materials/upload',
      builder: (context, state) {
        final batch = state.extra as BatchModel?;
        return UploadMaterialPage(batch: batch);
      },
    ),
    GoRoute(
      path: '/materials/view',
      builder: (context, state) {
        final batch = state.extra as BatchModel?;
        if (batch == null) {
          return const BatchesPage();
        }
        return BatchMaterialsPage(batch: batch);
      },
    ),

    // Setting Route
    GoRoute(
      path: '/premium',
      builder: (context, state) => const PremiumPage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);
