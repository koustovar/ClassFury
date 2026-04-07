import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:classfury/core/constants/firebase_constants.dart';
import '../models/exam_model.dart';

abstract class ExamsRemoteDataSource {
  Future<ExamModel> createExam(ExamModel exam);
  Future<List<ExamModel>> getBatchExams(String batchId);
  Future<List<ExamModel>> getTeacherExams(String teacherId);
  Future<void> updateExamStatus(String examId, ExamStatus status);
  Future<void> deleteExam(String examId);
  Future<String> uploadExamFile(String examId, File file);
  Future<void> submitExamAnswer(Map<String, dynamic> submission);
}

class ExamsRemoteDataSourceImpl implements ExamsRemoteDataSource {
  final FirebaseFirestore _firestore;
  final Dio _dio;

  ExamsRemoteDataSourceImpl(this._firestore, this._dio);

  @override
  Future<ExamModel> createExam(ExamModel exam) async {
    final docRef =
        _firestore.collection(FirebaseConstants.examsCollection).doc();

    final newExam = ExamModel(
      id: docRef.id,
      batchId: exam.batchId,
      teacherId: exam.teacherId,
      title: exam.title,
      description: exam.description,
      startTime: exam.startTime,
      durationMinutes: exam.durationMinutes,
      gracePeriodMinutes: exam.gracePeriodMinutes,
      questionUrl: exam.questionUrl,
      questions: exam.questions,
      status: exam.status,
      totalMarks: exam.questions.isEmpty
          ? exam.totalMarks
          : exam.questions.fold(0, (total, q) => total + q.marks),
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
    await _firestore
        .collection(FirebaseConstants.examsCollection)
        .doc(examId)
        .delete();
  }

  @override
  Future<String> uploadExamFile(String examId, File file) async {
    try {
      final fileName = path.basename(file.path);
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        'fileName': fileName,
        'folder': '/exams/$examId',
        'useUniqueFileName': true,
      });

      final basicAuth =
          'Basic ${base64Encode(utf8.encode('${FirebaseConstants.imageKitPrivateKey}:'))}';

      final response = await _dio.post(
        FirebaseConstants.imageKitUploadEndpoint,
        data: formData,
        options: Options(
          headers: {
            'Authorization': basicAuth,
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('ImageKit upload failed: ${response.data}');
      }

      return response.data['url'] as String;
    } on DioException catch (e) {
      final errorMsg = e.response?.data != null
          ? e.response?.data['message'] ?? e.response?.data.toString()
          : e.message;
      throw Exception('ImageKit upload error: $errorMsg');
    } catch (e) {
      throw Exception('Unexpected upload error: $e');
    }
  }

  @override
  Future<void> submitExamAnswer(Map<String, dynamic> submission) async {
    final docRef = _firestore
        .collection(FirebaseConstants.examsCollection)
        .doc(submission['examId'])
        .collection('submissions')
        .doc(submission['studentId']);
    await docRef.set(submission);
  }
}
