import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String role; // 'teacher' | 'student'
  final String photoUrl;
  final DateTime createdAt;
  final bool isPremium;
  final bool isEmailVerified;

  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.photoUrl,
    required this.createdAt,
    required this.isPremium,
    this.isEmailVerified = false,
  });

  @override
  List<Object?> get props => [uid, name, email, phoneNumber, role, photoUrl, createdAt, isPremium, isEmailVerified];
}
