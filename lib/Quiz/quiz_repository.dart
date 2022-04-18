import 'dart:io';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dio/dio.dart';
import '/Models/failure_model.dart';
import '/Enums/difficulty.dart';
import '/Models/question_model.dart';
import 'base_quiz_repository.dart';

final dioProvider = Provider<Dio>((ref) => Dio());

final quizRepositoryProvider =
    Provider<QuizRepository>((ref) => QuizRepository(ref.read));

class QuizRepository extends BaseQuizRositry {
  //ここにはある↓
  final Reader _read;
  QuizRepository(this._read);

  @override
  Future<List<Question>> getQuestion({
    int? numQuestion,
    int? categoryId,
    Difficulty? difficulty,
  }) async {
    try {
      final queryParameters = {
        'type': 'multiple',
        'amount': 'numQuestion',
        'category': 'categoryId',
      };

      if (difficulty != Difficulty.any) {
        queryParameters
            .addAll({'difficulty': EnumToString.convertToString(difficulty)});
      }

      final response = await _read(dioProvider).get(
        'https://opentdb.com/api.php?amount=10',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(response.data);
        final results = List<Map<String, dynamic>>.from(data['results']);
        //final results = Map<String, dynamic>.from(data['results']) as List;
        if (results.isNotEmpty) {
          return results.map((e) => Question.fromMap(e)).toList();
        }
      }
      return [];
    } on DioError catch (err) {
      print(err);
      throw Failure(
          message: err.response?.statusMessage ?? ' Something went wrong!');
    } on SocketException catch (err) {
      print(err);
      throw const Failure(message: 'Please check your connection.');
    }
  }
}
