import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:classfury/firebase_options.dart';
import 'package:classfury/app/router/app_router.dart';
import 'package:classfury/app/theme/app_theme.dart';
import 'package:classfury/app/theme/bloc/theme_cubit.dart';
import 'package:classfury/core/di/injection.dart';
import 'package:classfury/core/services/notification_service.dart';
import 'package:classfury/core/services/payment_service.dart';
import 'package:classfury/features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 0. Load environment variables
  try {
    await dotenv.load();
  } catch (e) {
    debugPrint('Warning: Failed to load .env file: $e');
  }

  // 1. Initialize Firebase first
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Configure dependencies (DI)
  await configureDependencies();

  // 3. Initialize background services — failures should not block app launch
  try {
    await getIt<NotificationService>().initialize();
  } catch (e) {
    debugPrint('Warning: NotificationService init failed: $e');
  }

  try {
    getIt<PaymentService>().initialize();
  } catch (e) {
    debugPrint('Warning: PaymentService init failed: $e');
  }

  runApp(const ClassFuryApp());
}

class ClassFuryApp extends StatelessWidget {
  const ClassFuryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) =>
              getIt<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider<ThemeCubit>(
          create: (context) => getIt<ThemeCubit>(),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            appRouter.go('/auth/login');
          } else if (state is AuthAuthenticated) {
            final currentLocation =
                appRouter.routerDelegate.currentConfiguration.uri.toString();
            if (currentLocation.startsWith('/auth')) {
              final dashboardPath = state.user.role == 'teacher'
                  ? '/teacher/dashboard'
                  : '/student/dashboard';
              appRouter.go(dashboardPath);
            }
          }
        },
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp.router(
              title: 'ClassFury',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              routerConfig: appRouter,
            );
          },
        ),
      ),
    );
  }
}
