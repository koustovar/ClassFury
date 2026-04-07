import 'package:dartz/dartz.dart';
import 'package:classfury/core/errors/failures.dart';
import 'package:classfury/features/auth/domain/repositories/auth_repository.dart';

class SaveStudentDetailsUseCase {
  final AuthRepository _repository;

  SaveStudentDetailsUseCase(this._repository);

  Future<Either<Failure, void>> call(SaveStudentDetailsParams params) {
    return _repository.saveStudentDetails(
      uid: params.uid,
      studentName: params.studentName,
      guardianName: params.guardianName,
      studentPhone: params.studentPhone,
      className: params.className,
      schoolName: params.schoolName,
      board: params.board,
    );
  }
}

class SaveStudentDetailsParams {
  final String uid;
  final String studentName;
  final String guardianName;
  final String studentPhone;
  final String className;
  final String schoolName;
  final String board;

  SaveStudentDetailsParams({
    required this.uid,
    required this.studentName,
    required this.guardianName,
    required this.studentPhone,
    required this.className,
    required this.schoolName,
    required this.board,
  });
}
