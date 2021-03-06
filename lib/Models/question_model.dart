import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class Question extends Equatable {
  late String category;
  late String difficulty;
  late String question;
  late String correctAnswer;
  late List<String> answers;

  Question({
    required this.category,
    required this.difficulty,
    required this.question,
    required this.correctAnswer,
    required this.answers,
  });

  @override
  List<Object> get props => [
        category,
        difficulty,
        question,
        correctAnswer,
        answers,
      ];
//インスタンス化しない/mapからQuestioのインスタンスを作る/Map<>でString,dynamicを紐付けてる
  static Question? fromMap(Map<String, dynamic> map) {
    // ignore: unnecessary_null_comparison
    return Question(
      //String:dynamic (Mapの中身)紐付いてる部分
      category: map['category'] ?? '',
      difficulty: map['difficulty'] ?? '',
      question: map['question'] ?? '',
      correctAnswer: map['correct_answer'] ?? '',
      answers: List<String>.from(map['incorrect_answers'] ?? [])
        ..add(map['correct_answer'] ?? '')
        ..shuffle(),
    );
  }
}
