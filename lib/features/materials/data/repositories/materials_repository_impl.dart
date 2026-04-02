import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../models/material_model.dart';
import '../datasources/materials_remote_datasource.dart';

abstract class MaterialsRepository {
  Future<Either<Failure, MaterialModel>> uploadMaterial(MaterialModel material, File file);
  Future<Either<Failure, List<MaterialModel>>> getBatchMaterials(String batchId);
  Future<Either<Failure, void>> deleteMaterial(String materialId, String fileUrl);
}

class MaterialsRepositoryImpl implements MaterialsRepository {
  final MaterialsRemoteDataSource _remoteDataSource;

  MaterialsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, MaterialModel>> uploadMaterial(MaterialModel material, File file) async {
    try {
      final result = await _remoteDataSource.uploadMaterial(material, file);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MaterialModel>>> getBatchMaterials(String batchId) async {
    try {
      final result = await _remoteDataSource.getBatchMaterials(batchId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMaterial(String materialId, String fileUrl) async {
    try {
      await _remoteDataSource.deleteMaterial(materialId, fileUrl);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
