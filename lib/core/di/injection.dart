import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';
import '../services/notification_service.dart';
import '../services/purchase_service.dart';
import '../../app/theme/bloc/theme_cubit.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/batches/data/datasources/batches_remote_datasource.dart';
import '../../features/batches/data/repositories/batches_repository_impl.dart';
import '../../features/batches/presentation/bloc/batches_cubit.dart';
import '../../features/batches/presentation/bloc/batch_requests_cubit.dart';
import '../../features/notices/data/datasources/notices_remote_datasource.dart';
import '../../features/notices/data/repositories/notices_repository_impl.dart';
import '../../features/exams/data/datasources/exams_remote_datasource.dart';
import '../../features/exams/data/repositories/exams_repository_impl.dart';
import '../../features/attendance/data/datasources/attendance_remote_datasource.dart';
import '../../features/attendance/data/repositories/attendance_repository_impl.dart';
import '../../features/classes/data/datasources/classes_remote_datasource.dart';
import '../../features/classes/data/repositories/classes_repository_impl.dart';
import '../../features/materials/data/datasources/materials_remote_datasource.dart';
import '../../features/materials/data/repositories/materials_repository_impl.dart';
import '../../features/analytics/data/repositories/analytics_repository_impl.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // Firebase
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  getIt.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());
  getIt.registerLazySingleton<PurchaseService>(() => PurchaseService());
  getIt.registerLazySingleton<FirebaseMessaging>(() => FirebaseMessaging.instance);
  getIt.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());
  getIt.registerLazySingleton<ThemeCubit>(() => ThemeCubit());
  getIt.registerLazySingleton<Dio>(() => Dio());

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
    () => ExamsRemoteDataSourceImpl(getIt<FirebaseFirestore>()),
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
  getIt.registerLazySingleton<SignUpUseCase>(() => SignUpUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton<SignInUseCase>(() => SignInUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton<SignOutUseCase>(() => SignOutUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton<GetCurrentUserUseCase>(
      () => GetCurrentUserUseCase(getIt<AuthRepository>()));

  // Blocs
  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      signUpUseCase: getIt<SignUpUseCase>(),
      signInUseCase: getIt<SignInUseCase>(),
      signOutUseCase: getIt<SignOutUseCase>(),
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
    ),
  );

  getIt.registerLazySingleton<BatchesCubit>(
    () => BatchesCubit(getIt<BatchesRepository>()),
  );
  
  getIt.registerLazySingleton<BatchRequestsCubit>(
    () => BatchRequestsCubit(getIt<BatchesRepository>()),
  );
}
