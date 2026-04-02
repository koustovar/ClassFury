import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String role; // 'teacher' | 'student'
  final String photoUrl;
  final DateTime createdAt;
  final bool isPremium;

  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.photoUrl,
    required this.createdAt,
    required this.isPremium,
  });

  @override
  List<Object?> get props => [uid, name, email, role, photoUrl, createdAt, isPremium];
}
