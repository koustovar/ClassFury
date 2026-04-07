import 'package:dartz/dartz.dart';
import 'package:classfury/core/errors/failures.dart';
import 'package:classfury/features/auth/domain/repositories/auth_repository.dart';

class SaveTeacherDetailsUseCase {
  final AuthRepository _repository;

  SaveTeacherDetailsUseCase(this._repository);

  Future<Either<Failure, void>> call(SaveTeacherDetailsParams params) {
    return _repository.saveTeacherDetails(
      uid: params.uid,
      name: params.name,
      phoneNumber: params.phoneNumber,
      subject: params.subject,
      qualification: params.qualification,
      tuitionType: params.tuitionType,
      description: params.description,
      profilePictureUrl: params.profilePictureUrl,
    );
  }
}

class SaveTeacherDetailsParams {
  final String uid;
  final String name;
  final String phoneNumber;
  final String subject;
  final String qualification;
  final String tuitionType;
  final String description;
  final String profilePictureUrl;

  SaveTeacherDetailsParams({
    required this.uid,
    required this.name,
    required this.phoneNumber,
    required this.subject,
    required this.qualification,
    required this.tuitionType,
    required this.description,
    required this.profilePictureUrl,
  });
}
