import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthSuccess extends AuthState {
  final String message;
  const AuthSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthStudentNeedsDetails extends AuthState {
  final UserEntity user;
  const AuthStudentNeedsDetails(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthTeacherNeedsDetails extends AuthState {
  final UserEntity user;
  const AuthTeacherNeedsDetails(this.user);

  @override
  List<Object?> get props => [user];
}
