import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signUpWithEmail(String email, String password, String name, String role);
  Future<UserModel> signInWithEmail(String email, String password);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Stream<User?> get authStateChanges;
  Future<UserModel?> getCurrentUserData();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  @override
  Future<UserModel> signUpWithEmail(
    String email, String password, String name, String role) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email, password: password);
    
    if (credential.user == null) throw Exception('User creation failed');
    
    await credential.user!.updateDisplayName(name);

    final userModel = UserModel(
      uid: credential.user!.uid,
      name: name,
      email: email,
      role: role,
      photoUrl: '',
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
          });
    } else {
      await _firestore
          .collection(FirebaseConstants.studentsCollection)
          .doc(credential.user!.uid)
          .set({
            'userId': credential.user!.uid, 
            'batchIds': [], 
            'teacherIds': [],
            'createdAt': FieldValue.serverTimestamp(),
          });
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
    
    return UserModel.fromJson(doc.data()!);
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
}
