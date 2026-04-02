import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum MaterialType { assignment, notes, book, other }

class MaterialModel extends Equatable {
  final String id;
  final String batchId;
  final String teacherId;
  final String title;
  final String description;
  final String fileUrl;
  final String fileName;
  final MaterialType type;
  final DateTime? deadline;
  final DateTime createdAt;

  const MaterialModel({
    required this.id,
    required this.batchId,
    required this.teacherId,
    required this.title,
    required this.description,
    required this.fileUrl,
    required this.fileName,
    required this.type,
    this.deadline,
    required this.createdAt,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'] as String,
      batchId: json['batchId'] as String,
      teacherId: json['teacherId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      fileUrl: json['fileUrl'] as String,
      fileName: json['fileName'] as String,
      type: MaterialType.values.byName(json['type'] as String),
      deadline: json['deadline'] != null ? (json['deadline'] as Timestamp).toDate() : null,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batchId': batchId,
      'teacherId': teacherId,
      'title': title,
      'description': description,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'type': type.name,
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  @override
  List<Object?> get props => [id, batchId, title, fileUrl];
}
