import 'package:equatable/equatable.dart';

enum QuestionType { mcq, trueFalse, shortAnswer }

class QuestionModel extends Equatable {
  final String id;
  final String text;
  final QuestionType type;
  final List<String> options; // Relevant for MCQ
  final String correctAnswer;
  final int marks;
  final String? imageUrl;

  const QuestionModel({
    required this.id,
    required this.text,
    required this.type,
    required this.options,
    required this.correctAnswer,
    required this.marks,
    this.imageUrl,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      text: json['text'] as String,
      type: QuestionType.values.byName(json['type'] as String),
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] as String,
      marks: json['marks'] as int? ?? 1,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'type': type.name,
      'options': options,
      'correctAnswer': correctAnswer,
      'marks': marks,
      'imageUrl': imageUrl,
    };
  }

  @override
  List<Object?> get props => [id, text, type, correctAnswer, marks];
}
