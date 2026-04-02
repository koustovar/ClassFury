import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:classfury/core/constants/firebase_constants.dart';
import '../models/class_model.dart';

abstract class ClassesRemoteDataSource {
  Future<ClassModel> scheduleClass(ClassModel classData);
  Future<List<ClassModel>> getBatchClasses(String batchId);
  Future<List<ClassModel>> getTeacherClasses(String teacherId);
  Future<void> updateClassStatus(String classId, bool isLive);
  Future<void> deleteClass(String classId);
}

class ClassesRemoteDataSourceImpl implements ClassesRemoteDataSource {
  final FirebaseFirestore _firestore;

  ClassesRemoteDataSourceImpl(this._firestore);

  @override
  Future<ClassModel> scheduleClass(ClassModel classData) async {
    final docRef = _firestore.collection(FirebaseConstants.classesCollection).doc();
    
    final newClass = ClassModel(
      id: docRef.id,
      batchId: classData.batchId,
      teacherId: classData.teacherId,
      title: classData.title,
      description: classData.description,
      startTime: classData.startTime,
      endTime: classData.endTime,
      meetingLink: classData.meetingLink,
      isLive: false,
    );

    await docRef.set(newClass.toJson());
    return newClass;
  }

  @override
  Future<List<ClassModel>> getBatchClasses(String batchId) async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.classesCollection)
        .where('batchId', isEqualTo: batchId)
        .orderBy('startTime', descending: false)
        .get();
        
    return snapshot.docs.map((doc) => ClassModel.fromJson(doc.data())).toList();
  }

  @override
  Future<List<ClassModel>> getTeacherClasses(String teacherId) async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.classesCollection)
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('startTime', descending: false)
        .get();
        
    return snapshot.docs.map((doc) => ClassModel.fromJson(doc.data())).toList();
  }

  @override
  Future<void> updateClassStatus(String classId, bool isLive) async {
    await _firestore
        .collection(FirebaseConstants.classesCollection)
        .doc(classId)
        .update({'isLive': isLive});
  }

  @override
  Future<void> deleteClass(String classId) async {
    await _firestore.collection(FirebaseConstants.classesCollection).doc(classId).delete();
  }
}
