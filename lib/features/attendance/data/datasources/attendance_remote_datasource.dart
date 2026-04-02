import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../models/attendance_model.dart';

abstract class AttendanceRemoteDataSource {
  Future<void> submitAttendance(AttendanceModel attendance);
  Future<List<AttendanceModel>> getBatchAttendance(String batchId);
  Future<List<AttendanceModel>> getStudentAttendance(String studentId, String batchId);
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final FirebaseFirestore _firestore;

  AttendanceRemoteDataSourceImpl(this._firestore);

  @override
  Future<void> submitAttendance(AttendanceModel attendance) async {
    final docRef = _firestore
        .collection(FirebaseConstants.batchesCollection)
        .doc(attendance.batchId)
        .collection(FirebaseConstants.attendanceCollection)
        .doc();
    
    final recordWithId = AttendanceModel(
      id: docRef.id,
      batchId: attendance.batchId,
      teacherId: attendance.teacherId,
      date: attendance.date,
      records: attendance.records,
      presentCount: attendance.presentCount,
      totalCount: attendance.totalCount,
    );

    await docRef.set(recordWithId.toJson());
  }

  @override
  Future<List<AttendanceModel>> getBatchAttendance(String batchId) async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.batchesCollection)
        .doc(batchId)
        .collection(FirebaseConstants.attendanceCollection)
        .orderBy('date', descending: true)
        .get();
        
    return snapshot.docs.map((doc) => AttendanceModel.fromJson(doc.data())).toList();
  }

  @override
  Future<List<AttendanceModel>> getStudentAttendance(String studentId, String batchId) async {
    // This is a more complex query, typically would involve searching within the 'records' array
    // Firestore isn't great at searching within arrays of objects. 
    // Usually, you'd store a separate collection for student-specific attendance if this is a frequent query.
    // For now, we'll fetch all and filter in memory or assume batch-level focus.
    final snapshot = await _firestore
        .collection(FirebaseConstants.batchesCollection)
        .doc(batchId)
        .collection(FirebaseConstants.attendanceCollection)
        .get();
        
    return snapshot.docs
        .map((doc) => AttendanceModel.fromJson(doc.data()))
        .where((a) => a.records.any((r) => r.studentId == studentId))
        .toList();
  }
}
