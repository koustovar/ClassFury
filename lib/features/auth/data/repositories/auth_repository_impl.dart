import 'package:dartz/dartz.dart';
import 'package:classfury/core/errors/failures.dart';
import 'package:classfury/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:classfury/features/auth/domain/repositories/auth_repository.dart';
import 'package:classfury/features/auth/domain/entities/user_entity.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String role,
  }) async {
    try {
      final user = await _remoteDataSource.signUpWithEmail(
          email, password, name, phoneNumber, role);
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.signInWithEmail(email, password);
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await _remoteDataSource.sendPasswordResetEmail(email);
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUserData();
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    required String uid,
    String? name,
    String? photoUrl,
  }) async {
    try {
      await _remoteDataSource.updateProfile(
          uid: uid, name: name, photoUrl: photoUrl);
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUserDetails(String uid) async {
    try {
      final user = await _remoteDataSource.getUserDetails(uid);
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveStudentDetails({
    required String uid,
    required String studentName,
    required String guardianName,
    required String studentPhone,
    required String className,
    required String schoolName,
    required String board,
  }) async {
    try {
      await _remoteDataSource.saveStudentDetails(
        uid: uid,
        studentName: studentName,
        guardianName: guardianName,
        studentPhone: studentPhone,
        className: className,
        schoolName: schoolName,
        board: board,
      );
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> hasStudentDetails(String uid) async {
    try {
      final hasDetails = await _remoteDataSource.hasStudentDetails(uid);
      return Right(hasDetails);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveTeacherDetails({
    required String uid,
    required String name,
    required String phoneNumber,
    required String subject,
    required String qualification,
    required String tuitionType,
    required String description,
    required String profilePictureUrl,
  }) async {
    try {
      await _remoteDataSource.saveTeacherDetails(
        uid: uid,
        name: name,
        phoneNumber: phoneNumber,
        subject: subject,
        qualification: qualification,
        tuitionType: tuitionType,
        description: description,
        profilePictureUrl: profilePictureUrl,
      );
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> hasTeacherDetails(String uid) async {
    try {
      final hasDetails = await _remoteDataSource.hasTeacherDetails(uid);
      return Right(hasDetails);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}
