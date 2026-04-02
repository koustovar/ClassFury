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
  final String role;
  
  const SignUpRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
  });
  
  @override
  List<Object?> get props => [email, name, role];
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
