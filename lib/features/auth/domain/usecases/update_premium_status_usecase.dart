import 'package:dartz/dartz.dart';
import 'package:classfury/core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class UpdatePremiumStatusUseCase {
  final AuthRepository _repository;

  UpdatePremiumStatusUseCase(this._repository);

  Future<Either<Failure, void>> call(UpdatePremiumStatusParams params) async {
    return await _repository.updatePremiumStatus(
      uid: params.uid,
      isPremium: params.isPremium,
    );
  }
}

class UpdatePremiumStatusParams {
  final String uid;
  final bool isPremium;

  UpdatePremiumStatusParams({
    required this.uid,
    required this.isPremium,
  });
}