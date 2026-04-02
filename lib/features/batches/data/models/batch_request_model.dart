import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum BatchRequestStatus { pending, accepted, rejected }

class BatchRequestModel extends Equatable {
  final String id;
  final String batchId;
  final String batchName;
  final String studentId;
  final String studentName;
  final String teacherId;
  final BatchRequestStatus status;
  final DateTime createdAt;

  const BatchRequestModel({
    required this.id,
    required this.batchId,
    required this.batchName,
    required this.studentId,
    required this.studentName,
    required this.teacherId,
    required this.status,
    required this.createdAt,
  });

  factory BatchRequestModel.fromJson(Map<String, dynamic> json) {
    return BatchRequestModel(
      id: json['id'] as String,
      batchId: json['batchId'] as String,
      batchName: json['batchName'] as String,
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String,
      teacherId: json['teacherId'] as String,
      status: BatchRequestStatus.values.byName(json['status'] as String),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batchId': batchId,
      'batchName': batchName,
      'studentId': studentId,
      'studentName': studentName,
      'teacherId': teacherId,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  @override
  List<Object?> get props => [id, batchId, studentId, status];
}
