import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String role,
  });
  
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });
  
  Future<Either<Failure, void>> signOut();
  
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
  
  Future<Either<Failure, UserEntity?>> getCurrentUser();
}
