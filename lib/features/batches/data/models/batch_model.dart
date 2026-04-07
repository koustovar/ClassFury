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
  final int tuitionFees;

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
    required this.tuitionFees,
  });

  factory BatchModel.fromJson(Map<String, dynamic> json) {
    final tuitionValue = json['tuitionFees'];
    final tuitionFees = tuitionValue is int
        ? tuitionValue
        : tuitionValue is num
            ? tuitionValue.toInt()
            : 0;

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
      tuitionFees: tuitionFees,
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
      'tuitionFees': tuitionFees,
    };
  }

  @override
  List<Object?> get props =>
      [id, teacherId, name, subject, joinCode, studentCount, tuitionFees];
}
