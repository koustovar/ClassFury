import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.phoneNumber,
    required super.role,
    required super.photoUrl,
    required super.createdAt,
    required super.isPremium,
    super.isEmailVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String? ?? '',
      role: json['role'] as String,
      photoUrl: json['photoUrl'] as String? ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      isPremium: json['isPremium'] as bool? ?? false,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'isPremium': isPremium,
      'isEmailVerified': isEmailVerified,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      name: entity.name,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      role: entity.role,
      photoUrl: entity.photoUrl,
      createdAt: entity.createdAt,
      isPremium: entity.isPremium,
      isEmailVerified: entity.isEmailVerified,
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phoneNumber,
    String? role,
    String? photoUrl,
    DateTime? createdAt,
    bool? isPremium,
    bool? isEmailVerified,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      isPremium: isPremium ?? this.isPremium,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}
