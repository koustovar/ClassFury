import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String phoneNumber;
  final String role;

  const SignUpRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.phoneNumber,
    required this.role,
  });

  @override
  List<Object?> get props => [email, name, phoneNumber, role];
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email];
}

class GoogleSignInRequested extends AuthEvent {
  const GoogleSignInRequested();
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class UpdateProfileRequested extends AuthEvent {
  final String? name;
  final String? photoUrl;

  const UpdateProfileRequested({this.name, this.photoUrl});

  @override
  List<Object?> get props => [name, photoUrl];
}

class SaveStudentDetailsRequested extends AuthEvent {
  final String uid;
  final String studentName;
  final String guardianName;
  final String studentPhone;
  final String className;
  final String schoolName;
  final String board;

  const SaveStudentDetailsRequested({
    required this.uid,
    required this.studentName,
    required this.guardianName,
    required this.studentPhone,
    required this.className,
    required this.schoolName,
    required this.board,
  });

  @override
  List<Object?> get props => [
        uid,
        studentName,
        guardianName,
        studentPhone,
        className,
        schoolName,
        board
      ];
}

class CheckStudentDetailsRequested extends AuthEvent {
  final String uid;

  const CheckStudentDetailsRequested({required this.uid});

  @override
  List<Object?> get props => [uid];
}

class SaveTeacherDetailsRequested extends AuthEvent {
  final String uid;
  final String name;
  final String phoneNumber;
  final String subject;
  final String qualification;
  final String tuitionType;
  final String description;
  final String profilePictureUrl;

  const SaveTeacherDetailsRequested({
    required this.uid,
    required this.name,
    required this.phoneNumber,
    required this.subject,
    required this.qualification,
    required this.tuitionType,
    required this.description,
    required this.profilePictureUrl,
  });

  @override
  List<Object?> get props => [
        uid,
        name,
        phoneNumber,
        subject,
        qualification,
        tuitionType,
        description,
        profilePictureUrl
      ];
}
