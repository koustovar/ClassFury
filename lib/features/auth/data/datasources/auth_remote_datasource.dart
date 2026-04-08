import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:classfury/core/constants/firebase_constants.dart';
import '../models/user_model.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signUpWithEmail(String email, String password, String name,
      String phoneNumber, String role);
  Future<UserModel> signInWithEmail(String email, String password);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Stream<User?> get authStateChanges;
  Future<UserModel?> getCurrentUserData();
  Future<void> updateProfile(
      {required String uid, String? name, String? photoUrl});
  Future<UserModel> getUserDetails(String uid);
  Future<void> saveStudentDetails({
    required String uid,
    required String studentName,
    required String guardianName,
    required String studentPhone,
    required String className,
    required String schoolName,
    required String board,
  });
  Future<bool> hasStudentDetails(String uid);
  Future<void> saveTeacherDetails({
    required String uid,
    required String name,
    required String phoneNumber,
    required String subject,
    required String qualification,
    required String tuitionType,
    required String description,
    required String profilePictureUrl,
  });
  Future<bool> hasTeacherDetails(String uid);
  Future<void> updatePremiumStatus(String uid, bool isPremium);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  String _getGravatarUrl(String email) {
    final emailHash =
        md5.convert(utf8.encode(email.trim().toLowerCase())).toString();
    return 'https://www.gravatar.com/avatar/$emailHash?s=200&d=mp';
  }

  @override
  Future<UserModel> signUpWithEmail(String email, String password, String name,
      String phoneNumber, String role) async {
    final credential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    if (credential.user == null) throw Exception('User creation failed');

    final photoUrl = _getGravatarUrl(email);

    await credential.user!.updateDisplayName(name);
    await credential.user!.updatePhotoURL(photoUrl);

    // Check if email is actually real/valid by sending verification
    await credential.user!.sendEmailVerification();

    final userModel = UserModel(
      uid: credential.user!.uid,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      role: role,
      photoUrl: photoUrl,
      createdAt: DateTime.now(),
      isPremium: false,
    );

    await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(credential.user!.uid)
        .set(userModel.toJson());

    // Create role-specific document
    if (role == 'teacher') {
      await _firestore
          .collection(FirebaseConstants.teachersCollection)
          .doc(credential.user!.uid)
          .set({
        'userId': credential.user!.uid,
        'batchIds': [],
        'totalStudents': 0,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      await _firestore
          .collection(FirebaseConstants.studentsCollection)
          .doc(credential.user!.uid)
          .set({
        'userId': credential.user!.uid,
        'batchIds': [],
        'teacherIds': [],
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    return userModel;
  }

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);

    if (credential.user == null) throw Exception('Sign in failed');

    final doc = await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(credential.user!.uid)
        .get();

    if (!doc.exists) throw Exception('User data not found');

    final userModel = UserModel.fromJson(doc.data()!);

    // Update photo if it was empty
    if (userModel.photoUrl.isEmpty) {
      final photoUrl = _getGravatarUrl(email);
      await credential.user!.updatePhotoURL(photoUrl);
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(credential.user!.uid)
          .update({'photoUrl': photoUrl});
      return userModel.copyWith(photoUrl: photoUrl);
    }

    return userModel;
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  Future<UserModel?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(user.uid)
        .get();

    if (!doc.exists) return null;

    return UserModel.fromJson(doc.data()!);
  }

  @override
  Future<void> updateProfile(
      {required String uid, String? name, String? photoUrl}) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;

    if (updates.isNotEmpty) {
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .update(updates);

      final user = _auth.currentUser;
      if (user != null && user.uid == uid) {
        if (name != null) await user.updateDisplayName(name);
        if (photoUrl != null) await user.updatePhotoURL(photoUrl);
      }
    }
  }

  @override
  Future<UserModel> getUserDetails(String uid) async {
    final doc = await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(uid)
        .get();
    if (!doc.exists) throw Exception('User not found');
    return UserModel.fromJson(doc.data()!);
  }

  @override
  Future<void> saveStudentDetails({
    required String uid,
    required String studentName,
    required String guardianName,
    required String studentPhone,
    required String className,
    required String schoolName,
    required String board,
  }) async {
    await _firestore
        .collection(FirebaseConstants.studentsCollection)
        .doc(uid)
        .set({
      'studentName': studentName,
      'guardianName': guardianName,
      'studentPhone': studentPhone,
      'class': className,
      'schoolName': schoolName,
      'board': board,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<bool> hasStudentDetails(String uid) async {
    final doc = await _firestore
        .collection(FirebaseConstants.studentsCollection)
        .doc(uid)
        .get();
    if (!doc.exists) return false;
    final data = doc.data();
    return data != null &&
        data.containsKey('studentName') &&
        data['studentName'] != null;
  }

  @override
  Future<void> saveTeacherDetails({
    required String uid,
    required String name,
    required String phoneNumber,
    required String subject,
    required String qualification,
    required String tuitionType,
    required String description,
    required String profilePictureUrl,
  }) async {
    await _firestore
        .collection(FirebaseConstants.teachersCollection)
        .doc(uid)
        .set({
      'name': name,
      'phoneNumber': phoneNumber,
      'subject': subject,
      'qualification': qualification,
      'tuitionType': tuitionType,
      'description': description,
      'profilePictureUrl': profilePictureUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<bool> hasTeacherDetails(String uid) async {
    final doc = await _firestore
        .collection(FirebaseConstants.teachersCollection)
        .doc(uid)
        .get();
    if (!doc.exists) return false;
    final data = doc.data();
    return data != null && data.containsKey('name') && data['name'] != null;
  }

  @override
  Future<void> updatePremiumStatus(String uid, bool isPremium) async {
    await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(uid)
        .update({
      'isPremium': isPremium,
      'premiumSince': isPremium ? FieldValue.serverTimestamp() : null,
    });
  }
}
