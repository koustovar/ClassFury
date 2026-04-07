import 'package:dartz/dartz.dart';
import 'package:classfury/core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpParams {
  final String email;
  final String password;
  final String name;
  final String phoneNumber;
  final String role;

  SignUpParams({
    required this.email,
    required this.password,
    required this.name,
    required this.phoneNumber,
    required this.role,
  });
}

class SignUpUseCase {
  final AuthRepository _repository;

  SignUpUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call(SignUpParams params) {
    return _repository.signUpWithEmail(
      email: params.email,
      password: params.password,
      name: params.name,
      phoneNumber: params.phoneNumber,
      role: params.role,
    );
  }
}
