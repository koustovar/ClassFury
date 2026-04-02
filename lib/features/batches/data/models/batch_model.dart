import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class BatchModel extends Equatable {
  final String id;
  final String teacherId;
  final String name;
  final String subject;
  final String description;
  final String joinCode;
  final List<String> studentIds;
  final int studentCount;
  final DateTime createdAt;
  final String color; // Hex
  final bool isActive;

  const BatchModel({
    required this.id,
    required this.teacherId,
    required this.name,
    required this.subject,
    required this.description,
    required this.joinCode,
    required this.studentIds,
    required this.studentCount,
    required this.createdAt,
    required this.color,
    required this.isActive,
  });

  factory BatchModel.fromJson(Map<String, dynamic> json) {
    return BatchModel(
      id: json['id'] as String,
      teacherId: json['teacherId'] as String,
      name: json['name'] as String,
      subject: json['subject'] as String,
      description: json['description'] as String,
      joinCode: json['joinCode'] as String,
      studentIds: List<String>.from(json['studentIds'] ?? []),
      studentCount: json['studentCount'] as int? ?? 0,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      color: json['color'] as String? ?? '#2563EB',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacherId': teacherId,
      'name': name,
      'subject': subject,
      'description': description,
      'joinCode': joinCode,
      'studentIds': studentIds,
      'studentCount': studentCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'color': color,
      'isActive': isActive,
    };
  }

  @override
  List<Object?> get props => [id, teacherId, name, subject, joinCode, studentCount];
}
