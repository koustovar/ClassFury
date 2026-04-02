import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/dashboard/presentation/pages/teacher_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/student_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/settings_page.dart';
import '../../features/batches/presentation/pages/batches_page.dart';
import '../../features/batches/presentation/pages/create_batch_page.dart';
import '../../features/batches/presentation/pages/batch_board_page.dart';
import '../../features/batches/presentation/pages/batch_detail_subpages.dart';
import '../../features/batches/presentation/pages/join_batch_page.dart';
import '../../features/batches/presentation/pages/student_batch_detail_page.dart';
import '../../features/batches/data/models/batch_model.dart';
import '../../features/notices/presentation/pages/create_notice_page.dart';
import '../../features/exams/presentation/pages/create_exam_page.dart';
import '../../features/attendance/presentation/pages/take_attendance_page.dart';
import '../../features/classes/presentation/pages/schedule_class_page.dart';
import '../../features/analytics/presentation/pages/batch_progress_page.dart';
import '../../features/materials/presentation/pages/upload_material_page.dart';


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
      return authState.user.role == 'teacher' ? '/teacher/dashboard' : '/student/dashboard';
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
      path: '/student/join',
      builder: (context, state) => const JoinBatchPage(),
    ),
    GoRoute(
      path: '/student/batch-detail',
      builder: (context, state) {
        final batch = state.extra as BatchModel;
        return StudentBatchDetailPage(batch: batch);
      },
    ),
    
    // Teacher Routes
    GoRoute(
      path: '/teacher/dashboard',
      builder: (context, state) => const TeacherDashboardPage(),
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
        final batch = state.extra as BatchModel;
        return BatchBoardPage(batch: batch);
      },
    ),
    GoRoute(
      path: '/batches/students',
      builder: (context, state) => BatchStudentsPage(batch: state.extra as BatchModel),
    ),
    GoRoute(
      path: '/batches/requests',
      builder: (context, state) => BatchRequestsPage(batch: state.extra as BatchModel),
    ),
    GoRoute(
      path: '/batches/fees',
      builder: (context, state) => BatchFeesPage(batch: state.extra as BatchModel),
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
    
    // Setting Route
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);
