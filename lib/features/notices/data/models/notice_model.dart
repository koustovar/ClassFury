import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class NoticeModel extends Equatable {
  final String id;
  final String batchId;
  final String batchName; // Added batch name
  final String teacherId;
  final String title;
  final String content;
  final DateTime createdAt;
  final List<String> attachmentUrls;

  const NoticeModel({
    required this.id,
    required this.batchId,
    required this.batchName,
    required this.teacherId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.attachmentUrls,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    return NoticeModel(
      id: json['id'] as String,
      batchId: json['batchId'] as String,
      batchName: json['batchName'] as String? ?? 'General',
      teacherId: json['teacherId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      attachmentUrls: List<String>.from(json['attachmentUrls'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batchId': batchId,
      'batchName': batchName,
      'teacherId': teacherId,
      'title': title,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'attachmentUrls': attachmentUrls,
    };
  }

  @override
  List<Object?> get props => [id, batchId, batchName, title, content, createdAt];
}
