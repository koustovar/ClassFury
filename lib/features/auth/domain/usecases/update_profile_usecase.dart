import 'package:dartz/dartz.dart';
import 'package:classfury/core/errors/failures.dart';
import 'package:classfury/features/auth/domain/repositories/auth_repository.dart';

class UpdateProfileUseCase {
  final AuthRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<Either<Failure, void>> call(UpdateProfileParams params) {
    return _repository.updateProfile(
      uid: params.uid,
      name: params.name,
      photoUrl: params.photoUrl,
    );
  }
}

class UpdateProfileParams {
  final String uid;
  final String? name;
  final String? photoUrl;

  UpdateProfileParams({
    required this.uid,
    this.name,
    this.photoUrl,
  });
}
