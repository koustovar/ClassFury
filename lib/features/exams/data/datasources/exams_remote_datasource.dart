import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:classfury/core/constants/firebase_constants.dart';
import '../models/exam_model.dart';

abstract class ExamsRemoteDataSource {
  Future<ExamModel> createExam(ExamModel exam);
  Future<List<ExamModel>> getBatchExams(String batchId);
  Future<List<ExamModel>> getTeacherExams(String teacherId);
  Future<void> updateExamStatus(String examId, ExamStatus status);
  Future<void> deleteExam(String examId);
}

class ExamsRemoteDataSourceImpl implements ExamsRemoteDataSource {
  final FirebaseFirestore _firestore;

  ExamsRemoteDataSourceImpl(this._firestore);

  @override
  Future<ExamModel> createExam(ExamModel exam) async {
    final docRef = _firestore.collection(FirebaseConstants.examsCollection).doc();
    
    final newExam = ExamModel(
      id: docRef.id,
      batchId: exam.batchId,
      teacherId: exam.teacherId,
      title: exam.title,
      description: exam.description,
      startTime: exam.startTime,
      durationMinutes: exam.durationMinutes,
      questions: exam.questions,
      status: exam.status,
      totalMarks: exam.questions.fold(0, (total, q) => total + q.marks),
      createdAt: DateTime.now(),
    );

    await docRef.set(newExam.toJson());
    return newExam;
  }

  @override
  Future<List<ExamModel>> getBatchExams(String batchId) async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.examsCollection)
        .where('batchId', isEqualTo: batchId)
        .orderBy('startTime', descending: true)
        .get();
        
    return snapshot.docs.map((doc) => ExamModel.fromJson(doc.data())).toList();
  }

  @override
  Future<List<ExamModel>> getTeacherExams(String teacherId) async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.examsCollection)
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('createdAt', descending: true)
        .get();
        
    return snapshot.docs.map((doc) => ExamModel.fromJson(doc.data())).toList();
  }

  @override
  Future<void> updateExamStatus(String examId, ExamStatus status) async {
    await _firestore
        .collection(FirebaseConstants.examsCollection)
        .doc(examId)
        .update({'status': status.name});
  }

  @override
  Future<void> deleteExam(String examId) async {
    await _firestore.collection(FirebaseConstants.examsCollection).doc(examId).delete();
  }
}
