import 'package:equatable/equatable.dart';

class DashboardState extends Equatable {
  final int totalBatches;
  final int totalStudents;
  final int totalExams;
  final bool isLoading;
  final String? errorMessage;

  const DashboardState({
    required this.totalBatches,
    required this.totalStudents,
    required this.totalExams,
    required this.isLoading,
    this.errorMessage,
  });

  DashboardState copyWith({
    int? totalBatches,
    int? totalStudents,
    int? totalExams,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DashboardState(
      totalBatches: totalBatches ?? this.totalBatches,
      totalStudents: totalStudents ?? this.totalStudents,
      totalExams: totalExams ?? this.totalExams,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [totalBatches, totalStudents, totalExams, isLoading, errorMessage];
}
