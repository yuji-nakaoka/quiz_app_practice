import 'package:flutter_app_quiz/Models/question_model.dart';
import '/Enums/difficulty.dart';

abstract class BaseQuizRositry {
  Future<List<Question>> getQuestion({
    int numQuestion,
    int categoryId,
    Difficulty difficulty,
  });
}
