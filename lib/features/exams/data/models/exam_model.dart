import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'question_model.dart';

enum ExamStatus { draft, upcoming, live, completed }

class ExamModel extends Equatable {
  final String id;
  final String batchId;
  final String teacherId;
  final String title;
  final String description;
  final DateTime startTime;
  final int durationMinutes;
  final int gracePeriodMinutes;
  final String? questionUrl;
  final List<QuestionModel> questions;
  final ExamStatus status;
  final int totalMarks;
  final DateTime createdAt;

  const ExamModel({
    required this.id,
    required this.batchId,
    required this.teacherId,
    required this.title,
    required this.description,
    required this.startTime,
    required this.durationMinutes,
    required this.gracePeriodMinutes,
    this.questionUrl,
    required this.questions,
    required this.status,
    required this.totalMarks,
    required this.createdAt,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: json['id'] as String,
      batchId: json['batchId'] as String,
      teacherId: json['teacherId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startTime: (json['startTime'] as Timestamp).toDate(),
      durationMinutes: json['durationMinutes'] as int,
      gracePeriodMinutes: json['gracePeriodMinutes'] as int? ?? 10, // default 10
      questionUrl: json['questionUrl'] as String?,
      questions: (json['questions'] as List)
          .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
          .toList(),
      status: ExamStatus.values.byName(json['status'] as String),
      totalMarks: json['totalMarks'] as int,
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
      'startTime': Timestamp.fromDate(startTime),
      'durationMinutes': durationMinutes,
      'gracePeriodMinutes': gracePeriodMinutes,
      'questionUrl': questionUrl,
      'questions': questions.map((q) => q.toJson()).toList(),
      'status': status.name,
      'totalMarks': totalMarks,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  @override
  List<Object?> get props => [id, batchId, title, startTime, status];
}
