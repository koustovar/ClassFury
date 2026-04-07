import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:classfury/core/constants/firebase_constants.dart';
import 'package:classfury/features/auth/data/models/user_model.dart';
import '../models/batch_model.dart';
import '../models/batch_request_model.dart';
import 'dart:math';

abstract class BatchesRemoteDataSource {
  Future<BatchModel> createBatch(BatchModel batch);
  Future<List<BatchModel>> getTeacherBatches(String teacherId);
  Stream<List<BatchModel>> watchTeacherBatches(String teacherId);
  Future<List<BatchModel>> getStudentBatches(String studentId);
  Stream<List<BatchModel>> watchStudentBatches(String studentId);
  Future<BatchModel> getBatchByJoinCode(String joinCode);
  Future<void> requestToJoinBatch(
      String studentId, String studentName, String batchId);
  Future<void> deleteBatch(String batchId, String teacherId);
  Future<void> respondToBatchRequest(String requestId, bool accept);
  Stream<List<BatchRequestModel>> watchBatchRequests(
      {String? teacherId, String? batchId, String? studentId});
  Future<List<BatchRequestModel>> getBatchRequests(
      {String? teacherId, String? batchId, String? studentId});
  Future<List<UserModel>> getBatchStudents(List<String> studentIds);
}

class BatchesRemoteDataSourceImpl implements BatchesRemoteDataSource {
  final FirebaseFirestore _firestore;

  BatchesRemoteDataSourceImpl(this._firestore);

  @override
  Future<BatchModel> createBatch(BatchModel batch) async {
    final docRef =
        _firestore.collection(FirebaseConstants.batchesCollection).doc();
    final joinCode = _generateJoinCode();

    final newBatch = BatchModel(
      id: docRef.id,
      teacherId: batch.teacherId,
      name: batch.name,
      subject: batch.subject,
      description: batch.description,
      joinCode: joinCode,
      studentIds: const [],
      studentCount: 0,
      createdAt: DateTime.now(),
      color: batch.color,
      isActive: true,
      tuitionFees: batch.tuitionFees,
    );

    await docRef.set(newBatch.toJson());

    // Update teacher's batch list
    await _firestore
        .collection(FirebaseConstants.teachersCollection)
        .doc(batch.teacherId)
        .set({
      'batchIds': FieldValue.arrayUnion([docRef.id]),
    }, SetOptions(merge: true));

    return newBatch;
  }

  @override
  Future<List<BatchModel>> getTeacherBatches(String teacherId) async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.batchesCollection)
        .where('teacherId', isEqualTo: teacherId)
        .get();

    return snapshot.docs.map((doc) => BatchModel.fromJson(doc.data())).toList();
  }

  @override
  Stream<List<BatchModel>> watchTeacherBatches(String teacherId) {
    return _firestore
        .collection(FirebaseConstants.batchesCollection)
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BatchModel.fromJson(doc.data()))
            .toList());
  }

  @override
  Future<List<BatchModel>> getStudentBatches(String studentId) async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.batchesCollection)
        .where('studentIds', arrayContains: studentId)
        .get();

    return snapshot.docs.map((doc) => BatchModel.fromJson(doc.data())).toList();
  }

  @override
  Stream<List<BatchModel>> watchStudentBatches(String studentId) {
    return _firestore
        .collection(FirebaseConstants.batchesCollection)
        .where('studentIds', arrayContains: studentId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BatchModel.fromJson(doc.data()))
            .toList());
  }

  @override
  Future<BatchModel> getBatchByJoinCode(String joinCode) async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.batchesCollection)
        .where('joinCode', isEqualTo: joinCode)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty)
      throw Exception('No active batch found with this code');

    return BatchModel.fromJson(snapshot.docs.first.data());
  }

  @override
  Future<void> requestToJoinBatch(
      String studentId, String studentName, String batchId) async {
    final batchRef =
        _firestore.collection(FirebaseConstants.batchesCollection).doc(batchId);
    final batchSnap = await batchRef.get();
    if (!batchSnap.exists) throw Exception('Batch not found');
    final batch = BatchModel.fromJson(batchSnap.data()!);

    final requestRef =
        _firestore.collection(FirebaseConstants.joinRequestsCollection).doc();
    final joinRequest = BatchRequestModel(
      id: requestRef.id,
      batchId: batchId,
      batchName: batch.name,
      studentId: studentId,
      studentName: studentName,
      teacherId: batch.teacherId,
      status: BatchRequestStatus.pending,
      createdAt: DateTime.now(),
    );

    await requestRef.set(joinRequest.toJson());
  }

  @override
  Future<List<BatchRequestModel>> getBatchRequests(
      {String? teacherId, String? batchId, String? studentId}) async {
    Query query =
        _firestore.collection(FirebaseConstants.joinRequestsCollection);

    if (teacherId != null)
      query = query.where('teacherId', isEqualTo: teacherId);
    if (studentId != null)
      query = query.where('studentId', isEqualTo: studentId);
    if (batchId != null) query = query.where('batchId', isEqualTo: batchId);

    query = query.where('status', isEqualTo: BatchRequestStatus.pending.name);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) =>
            BatchRequestModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Stream<List<BatchRequestModel>> watchBatchRequests(
      {String? teacherId, String? batchId, String? studentId}) {
    Query query =
        _firestore.collection(FirebaseConstants.joinRequestsCollection);

    if (teacherId != null)
      query = query.where('teacherId', isEqualTo: teacherId);
    if (studentId != null)
      query = query.where('studentId', isEqualTo: studentId);
    if (batchId != null) query = query.where('batchId', isEqualTo: batchId);

    query = query.where('status', isEqualTo: BatchRequestStatus.pending.name);

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) =>
            BatchRequestModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList());
  }

  @override
  Future<void> respondToBatchRequest(String requestId, bool accept) async {
    final requestRef = _firestore
        .collection(FirebaseConstants.joinRequestsCollection)
        .doc(requestId);

    await _firestore.runTransaction((transaction) async {
      final requestSnap = await transaction.get(requestRef);
      if (!requestSnap.exists) throw Exception('Request not found');

      final joinRequest = BatchRequestModel.fromJson(
          requestSnap.data() as Map<String, dynamic>);

      if (accept) {
        final batchRef = _firestore
            .collection(FirebaseConstants.batchesCollection)
            .doc(joinRequest.batchId);

        transaction.update(batchRef, {
          'studentIds': FieldValue.arrayUnion([joinRequest.studentId]),
          'studentCount': FieldValue.increment(1),
        });

        transaction.set(
          _firestore
              .collection(FirebaseConstants.studentsCollection)
              .doc(joinRequest.studentId),
          {
            'batchIds': FieldValue.arrayUnion([joinRequest.batchId]),
            'teacherIds': FieldValue.arrayUnion([joinRequest.teacherId]),
          },
          SetOptions(merge: true),
        );

        transaction
            .update(requestRef, {'status': BatchRequestStatus.accepted.name});
      } else {
        transaction
            .update(requestRef, {'status': BatchRequestStatus.rejected.name});
      }
    });
  }

  @override
  Future<void> deleteBatch(String batchId, String teacherId) async {
    final batchRef =
        _firestore.collection(FirebaseConstants.batchesCollection).doc(batchId);

    await _firestore.runTransaction((transaction) async {
      // 1. Delete batch document
      transaction.delete(batchRef);

      // 2. Remove batch from teacher's batch list
      transaction.update(
        _firestore
            .collection(FirebaseConstants.teachersCollection)
            .doc(teacherId),
        {
          'batchIds': FieldValue.arrayRemove([batchId]),
        },
      );
    });
  }

  @override
  Future<List<UserModel>> getBatchStudents(List<String> studentIds) async {
    if (studentIds.isEmpty) return [];

    final snapshot = await _firestore
        .collection(FirebaseConstants.usersCollection)
        .where('uid', whereIn: studentIds)
        .get();

    return snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
  }

  String _generateJoinCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Avoid O, 0, I, 1
    return List.generate(6, (index) => chars[Random().nextInt(chars.length)])
        .join();
  }
}
