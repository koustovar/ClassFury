import 'package:equatable/equatable.dart';
import 'package:classfury/features/materials/data/models/material_model.dart';

abstract class MaterialsState extends Equatable {
  const MaterialsState();
  
  @override
  List<Object?> get props => [];
}

class MaterialsInitial extends MaterialsState {}

class MaterialsLoading extends MaterialsState {}

class MaterialsLoaded extends MaterialsState {
  final List<MaterialModel> materials;
  const MaterialsLoaded(this.materials);
  
  @override
  List<Object?> get props => [materials];
}

class MaterialUploaded extends MaterialsState {
  final MaterialModel material;
  const MaterialUploaded(this.material);
  
  @override
  List<Object?> get props => [material];
}

class MaterialsError extends MaterialsState {
  final String message;
  const MaterialsError(this.message);
  
  @override
  List<Object?> get props => [message];
}
