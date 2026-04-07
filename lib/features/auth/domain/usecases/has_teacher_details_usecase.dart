import 'package:dartz/dartz.dart';
import 'package:classfury/core/errors/failures.dart';
import 'package:classfury/features/auth/domain/repositories/auth_repository.dart';

class HasTeacherDetailsUseCase {
  final AuthRepository _repository;

  HasTeacherDetailsUseCase(this._repository);

  Future<Either<Failure, bool>> call(String uid) {
    return _repository.hasTeacherDetails(uid);
  }
}
