import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:classfury/core/constants/firebase_constants.dart';
import '../models/notice_model.dart';

abstract class NoticesRemoteDataSource {
  Future<NoticeModel> createNotice(NoticeModel notice);
  Future<List<NoticeModel>> getBatchNotices(String batchId);
  Future<List<NoticeModel>> getTeacherNotices(String teacherId);
  Future<void> deleteNotice(String noticeId);
  Stream<List<NoticeModel>> watchStudentNotices(List<String> batchIds);
}

class NoticesRemoteDataSourceImpl implements NoticesRemoteDataSource {
  final FirebaseFirestore _firestore;

  NoticesRemoteDataSourceImpl(this._firestore);

  @override
  Future<NoticeModel> createNotice(NoticeModel notice) async {
    final docRef = _firestore.collection(FirebaseConstants.noticesCollection).doc();
    
    final newNotice = NoticeModel(
      id: docRef.id,
      batchId: notice.batchId,
      batchName: notice.batchName,
      teacherId: notice.teacherId,
      title: notice.title,
      content: notice.content,
      createdAt: DateTime.now(),
      attachmentUrls: notice.attachmentUrls,
    );

    await docRef.set(newNotice.toJson());
    return newNotice;
  }

  @override
  Future<List<NoticeModel>> getBatchNotices(String batchId) async {
    final oneDayAgo = DateTime.now().subtract(const Duration(hours: 24));
    
    // Explicitly delete old messages
    try {
      final oldSnapshot = await _firestore
          .collection(FirebaseConstants.noticesCollection)
          .where('batchId', isEqualTo: batchId)
          .where('createdAt', isLessThan: Timestamp.fromDate(oneDayAgo))
          .get();
      for (var doc in oldSnapshot.docs) {
        doc.reference.delete();
      }
    } catch (e) {
      // Ignore permissions or other errors during lazy deletion
    }

    final snapshot = await _firestore
        .collection(FirebaseConstants.noticesCollection)
        .where('batchId', isEqualTo: batchId)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(oneDayAgo))
        .orderBy('createdAt', descending: true)
        .get();
        
    return snapshot.docs.map((doc) => NoticeModel.fromJson(doc.data())).toList();
  }

  @override
  Future<List<NoticeModel>> getTeacherNotices(String teacherId) async {
    final oneDayAgo = DateTime.now().subtract(const Duration(hours: 24));

    // Explicitly delete old messages for this teacher's notices
    try {
      final oldSnapshot = await _firestore
          .collection(FirebaseConstants.noticesCollection)
          .where('teacherId', isEqualTo: teacherId)
          .where('createdAt', isLessThan: Timestamp.fromDate(oneDayAgo))
          .get();
      for (var doc in oldSnapshot.docs) {
        doc.reference.delete();
      }
    } catch (e) {
      // Ignore permissions or other errors during lazy deletion
    }

    final snapshot = await _firestore
        .collection(FirebaseConstants.noticesCollection)
        .where('teacherId', isEqualTo: teacherId)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(oneDayAgo))
        .orderBy('createdAt', descending: true)
        .get();
        
    return snapshot.docs.map((doc) => NoticeModel.fromJson(doc.data())).toList();
  }

  @override
  Future<void> deleteNotice(String noticeId) async {
    await _firestore.collection(FirebaseConstants.noticesCollection).doc(noticeId).delete();
  }

  @override
  Stream<List<NoticeModel>> watchStudentNotices(List<String> batchIds) {
    if (batchIds.isEmpty) return Stream.value([]);
    
    // Changing from 7 days to 24 hours
    final oneDayAgo = DateTime.now().subtract(const Duration(hours: 24));
    
    final limitedBatchIds = batchIds.length > 30 ? batchIds.sublist(0, 30) : batchIds;

    return _firestore
        .collection(FirebaseConstants.noticesCollection)
        .where('batchId', whereIn: limitedBatchIds)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(oneDayAgo))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => NoticeModel.fromJson(doc.data())).toList());
  }
}
