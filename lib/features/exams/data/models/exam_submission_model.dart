import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'exam_page_model.dart';

class ExamSubmissionModel extends Equatable {
  final String id;
  final String examId;
  final String studentId;
  final List<ExamPageModel> pages;
  final DateTime submittedAt;
  final bool isLate;

  const ExamSubmissionModel({
    required this.id,
    required this.examId,
    required this.studentId,
    required this.pages,
    required this.submittedAt,
    required this.isLate,
  });

  factory ExamSubmissionModel.fromJson(Map<String, dynamic> json) {
    return ExamSubmissionModel(
      id: json['id'] as String,
      examId: json['examId'] as String,
      studentId: json['studentId'] as String,
      pages: (json['pages'] as List)
          .map((p) => ExamPageModel.fromJson(p as Map<String, dynamic>))
          .toList(),
      submittedAt: (json['submittedAt'] as Timestamp).toDate(),
      isLate: json['isLate'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'examId': examId,
      'studentId': studentId,
      'pages': pages.map((p) => p.toJson()).toList(),
      'submittedAt': Timestamp.fromDate(submittedAt),
      'isLate': isLate,
    };
  }

  @override
  List<Object?> get props => [id, examId, studentId, submittedAt, isLate];
}
