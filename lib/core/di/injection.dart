import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:classfury/core/services/notification_service.dart';
import 'package:classfury/core/services/payment_service.dart';
import 'package:classfury/core/services/url_launcher_service.dart';
import 'package:classfury/app/theme/bloc/theme_cubit.dart';

import 'package:classfury/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:classfury/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:classfury/features/auth/domain/repositories/auth_repository.dart';
import 'package:classfury/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:classfury/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:classfury/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:classfury/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:classfury/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:classfury/features/auth/domain/usecases/save_student_details_usecase.dart';
import 'package:classfury/features/auth/domain/usecases/has_student_details_usecase.dart';
import 'package:classfury/features/auth/domain/usecases/save_teacher_details_usecase.dart';
import 'package:classfury/features/auth/domain/usecases/has_teacher_details_usecase.dart';
import 'package:classfury/features/auth/domain/usecases/update_premium_status_usecase.dart';
import 'package:classfury/features/auth/presentation/bloc/auth_bloc.dart';

import 'package:classfury/features/batches/data/datasources/batches_remote_datasource.dart';
import 'package:classfury/features/batches/data/repositories/batches_repository_impl.dart';
import 'package:classfury/features/batches/presentation/bloc/batches_cubit.dart';
import 'package:classfury/features/batches/presentation/bloc/batch_requests_cubit.dart';
import 'package:classfury/features/notices/data/datasources/notices_remote_datasource.dart';
import 'package:classfury/features/notices/data/repositories/notices_repository_impl.dart';
import 'package:classfury/features/notices/presentation/bloc/notices_cubit.dart';
import 'package:classfury/features/exams/data/datasources/exams_remote_datasource.dart';
import 'package:classfury/features/exams/data/repositories/exams_repository_impl.dart';
import 'package:classfury/features/exams/presentation/bloc/exams_cubit.dart';
import 'package:classfury/features/attendance/data/datasources/attendance_remote_datasource.dart';
import 'package:classfury/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:classfury/features/classes/data/datasources/classes_remote_datasource.dart';
import 'package:classfury/features/classes/data/repositories/classes_repository_impl.dart';
import 'package:classfury/features/materials/data/datasources/materials_remote_datasource.dart';
import 'package:classfury/features/materials/data/repositories/materials_repository_impl.dart';
import 'package:classfury/features/materials/presentation/bloc/materials_cubit.dart';
import 'package:classfury/features/analytics/data/repositories/analytics_repository_impl.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  getIt.registerLazySingleton<Dio>(() => Dio());

  // Firebase
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance);
  getIt.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);
  getIt.registerLazySingleton<FirebaseMessaging>(
      () => FirebaseMessaging.instance);
  // GoogleSignIn - v7.2.0 handles initialization via platform channels
  // No direct instantiation needed in DI - access via GoogleSignIn methods directly
  // Uncomment and fix if your app needs specific GoogleSignIn configuration
  // getIt.registerSingleton<GoogleSignIn>(...);

  // Services
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());
  getIt.registerLazySingleton<PaymentService>(() => PaymentService());
  getIt.registerLazySingleton<UrlLauncherService>(() => UrlLauncherService());
  getIt.registerLazySingleton<ThemeCubit>(
      () => ThemeCubit(getIt<SharedPreferences>()));

  // Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      auth: getIt<FirebaseAuth>(),
      firestore: getIt<FirebaseFirestore>(),
    ),
  );
  getIt.registerLazySingleton<BatchesRemoteDataSource>(
    () => BatchesRemoteDataSourceImpl(getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<NoticesRemoteDataSource>(
    () => NoticesRemoteDataSourceImpl(getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<ExamsRemoteDataSource>(
    () => ExamsRemoteDataSourceImpl(getIt<FirebaseFirestore>(), getIt<Dio>()),
  );
  getIt.registerLazySingleton<AttendanceRemoteDataSource>(
    () => AttendanceRemoteDataSourceImpl(getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<ClassesRemoteDataSource>(
    () => ClassesRemoteDataSourceImpl(getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<MaterialsRemoteDataSource>(
    () => MaterialsRemoteDataSourceImpl(
      getIt<FirebaseFirestore>(),
      getIt<Dio>(),
    ),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
  );
  getIt.registerLazySingleton<BatchesRepository>(
    () => BatchesRepositoryImpl(getIt<BatchesRemoteDataSource>()),
  );
  getIt.registerLazySingleton<NoticesRepository>(
    () => NoticesRepositoryImpl(getIt<NoticesRemoteDataSource>()),
  );
  getIt.registerLazySingleton<ExamsRepository>(
    () => ExamsRepositoryImpl(getIt<ExamsRemoteDataSource>()),
  );
  getIt.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(getIt<AttendanceRemoteDataSource>()),
  );
  getIt.registerLazySingleton<ClassesRepository>(
    () => ClassesRepositoryImpl(getIt<ClassesRemoteDataSource>()),
  );
  getIt.registerLazySingleton<MaterialsRepository>(
    () => MaterialsRepositoryImpl(getIt<MaterialsRemoteDataSource>()),
  );
  getIt.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(
      getIt<ExamsRepository>(),
      getIt<AttendanceRepository>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton<SignUpUseCase>(
      () => SignUpUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton<SignInUseCase>(
      () => SignInUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton<SignOutUseCase>(
      () => SignOutUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton<GetCurrentUserUseCase>(
      () => GetCurrentUserUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton<UpdateProfileUseCase>(
      () => UpdateProfileUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton<SaveStudentDetailsUseCase>(
      () => SaveStudentDetailsUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton<HasStudentDetailsUseCase>(
      () => HasStudentDetailsUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton<SaveTeacherDetailsUseCase>(
      () => SaveTeacherDetailsUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton<HasTeacherDetailsUseCase>(
      () => HasTeacherDetailsUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton<UpdatePremiumStatusUseCase>(
      () => UpdatePremiumStatusUseCase(getIt<AuthRepository>()));

  // Blocs
  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      signUpUseCase: getIt<SignUpUseCase>(),
      signInUseCase: getIt<SignInUseCase>(),
      signOutUseCase: getIt<SignOutUseCase>(),
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
      updateProfileUseCase: getIt<UpdateProfileUseCase>(),
      saveStudentDetailsUseCase: getIt<SaveStudentDetailsUseCase>(),
      hasStudentDetailsUseCase: getIt<HasStudentDetailsUseCase>(),
      saveTeacherDetailsUseCase: getIt<SaveTeacherDetailsUseCase>(),
      hasTeacherDetailsUseCase: getIt<HasTeacherDetailsUseCase>(),
      updatePremiumStatusUseCase: getIt<UpdatePremiumStatusUseCase>(),
    ),
  );

  getIt.registerLazySingleton<BatchesCubit>(
    () => BatchesCubit(getIt<BatchesRepository>()),
  );

  getIt.registerLazySingleton<BatchRequestsCubit>(
    () => BatchRequestsCubit(getIt<BatchesRepository>()),
  );
  getIt.registerLazySingleton<NoticesCubit>(
    () => NoticesCubit(getIt<NoticesRepository>()),
  );

  // Inject ExamsCubit and MaterialsCubit
  getIt.registerFactory<ExamsCubit>(
    () => ExamsCubit(getIt<ExamsRepository>()),
  );

  getIt.registerFactory<MaterialsCubit>(
    () => MaterialsCubit(getIt<MaterialsRepository>()),
  );
}
