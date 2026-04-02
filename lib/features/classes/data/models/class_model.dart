import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ClassModel extends Equatable {
  final String id;
  final String batchId;
  final String teacherId;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String meetingLink;
  final bool isLive;

  const ClassModel({
    required this.id,
    required this.batchId,
    required this.teacherId,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.meetingLink,
    required this.isLive,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] as String,
      batchId: json['batchId'] as String,
      teacherId: json['teacherId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startTime: (json['startTime'] as Timestamp).toDate(),
      endTime: (json['endTime'] as Timestamp).toDate(),
      meetingLink: json['meetingLink'] as String,
      isLive: json['isLive'] as bool? ?? false,
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
      'endTime': Timestamp.fromDate(endTime),
      'meetingLink': meetingLink,
      'isLive': isLive,
    };
  }

  @override
  List<Object?> get props => [id, batchId, title, startTime, meetingLink];
}
