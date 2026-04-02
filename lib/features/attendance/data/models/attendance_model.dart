import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class AttendanceRecord extends Equatable {
  final String studentId;
  final String studentName;
  final bool isPresent;
  final String? note;

  const AttendanceRecord({
    required this.studentId,
    required this.studentName,
    required this.isPresent,
    this.note,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String,
      isPresent: json['isPresent'] as bool,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'isPresent': isPresent,
      'note': note,
    };
  }

  @override
  List<Object?> get props => [studentId, isPresent];
}

class AttendanceModel extends Equatable {
  final String id;
  final String batchId;
  final String teacherId;
  final DateTime date;
  final List<AttendanceRecord> records;
  final int presentCount;
  final int totalCount;

  const AttendanceModel({
    required this.id,
    required this.batchId,
    required this.teacherId,
    required this.date,
    required this.records,
    required this.presentCount,
    required this.totalCount,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as String,
      batchId: json['batchId'] as String,
      teacherId: json['teacherId'] as String,
      date: (json['date'] as Timestamp).toDate(),
      records: (json['records'] as List)
          .map((r) => AttendanceRecord.fromJson(r as Map<String, dynamic>))
          .toList(),
      presentCount: json['presentCount'] as int,
      totalCount: json['totalCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batchId': batchId,
      'teacherId': teacherId,
      'date': Timestamp.fromDate(date),
      'records': records.map((r) => r.toJson()).toList(),
      'presentCount': presentCount,
      'totalCount': totalCount,
    };
  }

  @override
  List<Object?> get props => [id, batchId, date, presentCount];
}
