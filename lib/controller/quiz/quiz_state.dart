import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '/Models/question_model.dart';

enum QuizStatus { initial, correct, incorrect, complete }

class QuizState extends Equatable {
  final String selectedAnswer;
  final List<String> incorrect;
  final List<String> correct;
  final QuizStatus status;

  bool get answered =>
      status == QuizStatus.incorrect || status == QuizStatus.correct;

  const QuizState({
    required this.selectedAnswer,
    required this.incorrect,
    required this.correct,
    required this.status,
  });

  factory QuizState.initial() {
    //const追加してる
    return const QuizState(
      selectedAnswer: '',
      incorrect: [],
      correct: [],
      status: QuizStatus.initial,
    );
  }

  @override
  List<Object> get props => [
        selectedAnswer,
        incorrect,
        correct,
        status,
      ];

  QuizState copyWith({
    required String selectedAnswer,
    required List<String> correct,
    required List<String> incorrect,
    required QuizStatus status,
  }) {
    return QuizState(
      selectedAnswer: selectedAnswer,
      correct: correct,
      incorrect: incorrect,
      status: status,
    );
  }
}
