import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:classfury/core/constants/firebase_constants.dart';
import '../models/notice_model.dart';

abstract class NoticesRemoteDataSource {
  Future<NoticeModel> createNotice(NoticeModel notice);
  Future<List<NoticeModel>> getBatchNotices(String batchId);
  Future<List<NoticeModel>> getTeacherNotices(String teacherId);
  Future<void> deleteNotice(String noticeId);
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
    final snapshot = await _firestore
        .collection(FirebaseConstants.noticesCollection)
        .where('batchId', isEqualTo: batchId)
        .orderBy('createdAt', descending: true)
        .get();
        
    return snapshot.docs.map((doc) => NoticeModel.fromJson(doc.data())).toList();
  }

  @override
  Future<List<NoticeModel>> getTeacherNotices(String teacherId) async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.noticesCollection)
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('createdAt', descending: true)
        .get();
        
    return snapshot.docs.map((doc) => NoticeModel.fromJson(doc.data())).toList();
  }

  @override
  Future<void> deleteNotice(String noticeId) async {
    await _firestore.collection(FirebaseConstants.noticesCollection).doc(noticeId).delete();
  }
}
