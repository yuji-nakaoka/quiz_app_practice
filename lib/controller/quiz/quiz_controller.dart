import 'package:flutter_app_quiz/Models/question_model.dart';
import 'package:flutter_app_quiz/controller/quiz/quiz_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final quizControllerProvider =
    StateNotifierProvider.autoDispose<QuizController, QuizState>(
  (ref) => QuizController(),
);

class QuizController extends StateNotifier<QuizState> {
  QuizController() : super(QuizState.initial());
  //ここには final Reader _read;が要らない

  void submitAnswer(Question currentQuestion, String answer) {
    if (state.answered) return;
    if (currentQuestion.correctAnswer == answer) {
      state = state.copyWith(
        //追加している　incorrect
        incorrect: [],
        selectedAnswer: answer,
        //QuestionをAnswerに変えてみた
        correct: state.correct..add(answer),
        status: QuizStatus.correct,
      );
    } else {
      state = state.copyWith(
        correct: [],
        selectedAnswer: answer,
        incorrect: state.incorrect..add(answer),
        status: QuizStatus.incorrect,
      );
    }
  }

  void nextQuestion(List<Question> questions, int currentIndex) {
    state = state.copyWith(
      selectedAnswer: '',
      correct: [],
      incorrect: [],
      status: currentIndex + 1 < questions.length
          ? QuizStatus.initial
          : QuizStatus.complete,
    );
  }

  void reset() {
    state = QuizState.initial();
  }
}
