import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:classfury/features/materials/data/models/material_model.dart';
import 'package:classfury/features/materials/data/repositories/materials_repository_impl.dart';
import 'materials_state.dart';

class MaterialsCubit extends Cubit<MaterialsState> {
  final MaterialsRepository _repository;

  MaterialsCubit(this._repository) : super(MaterialsInitial());

  Future<void> loadBatchMaterials(String batchId) async {
    emit(MaterialsLoading());
    final result = await _repository.getBatchMaterials(batchId);
    result.fold(
      (failure) => emit(MaterialsError(failure.message)),
      (materials) => emit(MaterialsLoaded(materials)),
    );
  }

  Future<void> uploadMaterial({
    required MaterialModel materialData,
    required File file,
  }) async {
    emit(MaterialsLoading());
    final result = await _repository.uploadMaterial(materialData, file);
    result.fold(
      (failure) => emit(MaterialsError(failure.message)),
      (material) => emit(MaterialUploaded(material)),
    );
  }

  Future<void> deleteMaterial(String materialId, String fileUrl) async {
    final result = await _repository.deleteMaterial(materialId, fileUrl);
    result.fold(
      (failure) => emit(MaterialsError(failure.message)),
      (_) {},
    );
  }
}
