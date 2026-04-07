import 'package:equatable/equatable.dart';

class ExamPageModel extends Equatable {
  final int pageNumber;
  final String url;

  const ExamPageModel({
    required this.pageNumber,
    required this.url,
  });

  factory ExamPageModel.fromJson(Map<String, dynamic> json) {
    return ExamPageModel(
      pageNumber: json['pageNumber'] as int,
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pageNumber': pageNumber,
      'url': url,
    };
  }

  @override
  List<Object?> get props => [pageNumber, url];
}
