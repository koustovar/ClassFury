import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:classfury/core/constants/firebase_constants.dart';
import '../models/material_model.dart';

abstract class MaterialsRemoteDataSource {
  Future<MaterialModel> uploadMaterial(MaterialModel material, File file);
  Future<List<MaterialModel>> getBatchMaterials(String batchId);
  Future<void> deleteMaterial(String materialId, String fileUrl);
}

class MaterialsRemoteDataSourceImpl implements MaterialsRemoteDataSource {
  final FirebaseFirestore _firestore;
  final Dio _dio;

  MaterialsRemoteDataSourceImpl(this._firestore, this._dio);

  @override
  Future<MaterialModel> uploadMaterial(MaterialModel material, File file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: material.fileName),
        'fileName': material.fileName,
        'folder': '/materials/${material.batchId}',
        'useUniqueFileName': 'true',
      });

      // Encode Private Key for Basic Auth
      final basicAuth = 'Basic ${base64Encode(utf8.encode('${FirebaseConstants.imageKitPrivateKey}:'))}';

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

      final downloadUrl = response.data['url'];

      // 2. Save record to Firestore
      final docRef = _firestore.collection(FirebaseConstants.materialsCollection).doc();
      final newMaterial = MaterialModel(
        id: docRef.id,
        batchId: material.batchId,
        teacherId: material.teacherId,
        title: material.title,
        description: material.description,
        fileUrl: downloadUrl,
        fileName: material.fileName,
        type: material.type,
        deadline: material.deadline,
        createdAt: DateTime.now(),
      );

      await docRef.set(newMaterial.toJson());
      return newMaterial;
    } on DioException catch (e) {
      final errorMsg = e.response?.data != null ? e.response?.data['message'] ?? e.response?.data.toString() : e.message;
      throw Exception('Upload failing: $errorMsg');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<List<MaterialModel>> getBatchMaterials(String batchId) async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.materialsCollection)
        .where('batchId', isEqualTo: batchId)
        .orderBy('createdAt', descending: true)
        .get();
        
    return snapshot.docs.map((doc) => MaterialModel.fromJson(doc.data())).toList();
  }

  @override
  Future<void> deleteMaterial(String materialId, String fileUrl) async {
    // 1. Delete record from Firestore
    await _firestore.collection(FirebaseConstants.materialsCollection).doc(materialId).delete();
    
    // 2. Delete file from ImageKit requires a server-side request with a Private Key.
    // For client-side, we primarily rely on record deletion.
  }
}
