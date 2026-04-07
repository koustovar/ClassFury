import 'package:dartz/dartz.dart';
import 'package:classfury/core/errors/failures.dart';
import 'package:classfury/features/auth/domain/repositories/auth_repository.dart';

class HasStudentDetailsUseCase {
  final AuthRepository _repository;

  HasStudentDetailsUseCase(this._repository);

  Future<Either<Failure, bool>> call(String uid) {
    return _repository.hasStudentDetails(uid);
  }
}
