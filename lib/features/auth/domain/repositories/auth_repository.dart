import 'package:dartz/dartz.dart';
import 'package:classfury/core/errors/failures.dart';
import 'package:classfury/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String role,
  });

  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  Future<Either<Failure, UserEntity?>> getCurrentUser();

  Future<Either<Failure, void>> updateProfile({
    required String uid,
    String? name,
    String? photoUrl,
  });

  Future<Either<Failure, void>> saveStudentDetails({
    required String uid,
    required String studentName,
    required String guardianName,
    required String studentPhone,
    required String className,
    required String schoolName,
    required String board,
  });

  Future<Either<Failure, bool>> hasStudentDetails(String uid);

  Future<Either<Failure, void>> saveTeacherDetails({
    required String uid,
    required String name,
    required String phoneNumber,
    required String subject,
    required String qualification,
    required String tuitionType,
    required String description,
    required String profilePictureUrl,
  });

  Future<Either<Failure, bool>> hasTeacherDetails(String uid);

  Future<Either<Failure, UserEntity>> getUserDetails(String uid);
}
