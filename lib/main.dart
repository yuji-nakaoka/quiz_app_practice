import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_app_quiz/Enums/difficulty.dart';
import 'package:flutter_app_quiz/Models/question_model.dart';
import 'package:flutter_app_quiz/Quiz/quiz_repository.dart';
import 'package:flutter_app_quiz/controller/quiz/quiz_controller.dart';
import 'package:flutter_app_quiz/controller/quiz/quiz_state.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html_character_entities/html_character_entities.dart';
import 'dart:math';
import 'Models/failure_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Flutter quiz app',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          bottomSheetTheme:
              const BottomSheetThemeData(backgroundColor: Colors.transparent),
        ),
        home: QuizScreen(),
      ),
    );
  }
}

final quizQuestionsProvider = FutureProvider.autoDispose<List<Question>>(
    ((ref) => ref.watch(quizRepositoryProvider).getQuestion(
          numQuestion: 5,
          categoryId: Random().nextInt(24) + 9,
          difficulty: Difficulty.any,
        )));

class QuizScreen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizQuestions = ref.watch(quizQuestionsProvider);
    final pageController = usePageController();
    return Container(
      //高さと横幅をコンテンツに合わせる
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        //グラデーションカラー
        gradient: LinearGradient(
          colors: [Color(0xFFD4418E), Color(0xFF0652C5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        //背景色を無効にする
        backgroundColor: Colors.transparent,
        body: quizQuestions.when(
          data: (date) => _buildBody(context, ref, pageController, date),
          error: (error, _) => QuizError(
              message:
                  error is Failure ? error.message : 'Something went wrong!'),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
        bottomSheet: quizQuestions.maybeWhen(
          data: (date) {
            final quizState = ref.watch(quizControllerProvider);
            if (!quizState.answered) return const SizedBox.shrink();
            return CustomBotton(
                title: pageController.page!.toInt() + 1 < date.length
                    ? 'Next Question'
                    : 'See Results',
                onTap: () {
                  ref
                      .read(quizControllerProvider.notifier)
                      .nextQuestion(date, pageController.page!.toInt());
                  if (pageController.page!.toInt() + 1 < date.length) {
                    pageController.nextPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.linear,
                    );
                  }
                });
          },
          orElse: () => const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    PageController pageController,
    List<Question> questions,
  ) {
    if (questions.isEmpty) return QuizError(message: 'No questions found.');

    final quizState = ref.watch(quizControllerProvider);
    return quizState.status == QuizStatus.complete
        ? QuizResults(state: quizState, questions: questions)
        : QuizQuestions(
            pageController: pageController,
            state: quizState,
            questions: questions,
          );
  }
}

class QuizError extends HookConsumerWidget {
  final String message;

  const QuizError({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 20.0),
          CustomBotton(
            title: 'Retry',
            onTap: () async => ref.refresh(quizRepositoryProvider),
          )
        ],
      ),
    );
  }
}

List<BoxShadow> boxshadow = const [
  BoxShadow(
    color: Colors.black26,
    offset: Offset(0, 2),
    blurRadius: 4.0,
  )
];

class CustomBotton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const CustomBotton({
    Key? key,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(20.0),
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.yellow,
          boxShadow: boxshadow,
          borderRadius: BorderRadius.circular(25.0),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class QuizResults extends HookConsumerWidget {
  final QuizState state;
  final List<Question> questions;

  const QuizResults({
    Key? key,
    required this.state,
    required this.questions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${state.correct.length}/${questions.length}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 60.0,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const Text(
            'CORRECT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 48.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40.0),
          CustomBotton(
            title: 'NEW QUIZ',
            onTap: () {
              ref.refresh(quizRepositoryProvider);
              ref.read(quizControllerProvider.notifier).reset();
            },
          )
        ]);
  }
}

class QuizQuestions extends HookConsumerWidget {
  final PageController pageController;
  final QuizState state;
  final List<Question> questions;

  const QuizQuestions(
      {Key? key,
      required this.pageController,
      required this.state,
      required this.questions})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      controller: pageController,
      physics: NeverScrollableScrollPhysics(),
      itemCount: questions.length,
      itemBuilder: (context, int index) {
        final question = questions[index];
        final questionlist = question.answers.cast<List>;
        return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            'Question ${index + 1} of ${questions.length}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 12.0),
            child: Text(
              HtmlCharacterEntities.decode(question.question),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Divider(
            color: Colors.grey[200],
            height: 32.0,
            thickness: 2.0,
            indent: 20.0,
            endIndent: 20.0,
          ),
          Column(
            children: question.answers
                .map(
                  (e) => AnswerCard(
                    answer: e,
                    isSelected: e == state.selectedAnswer,
                    isCorrect: e == question.correctAnswer,
                    isDisplayingAnswer: state.answered,
                    onTap: () => ref
                        .read(quizControllerProvider.notifier)
                        .submitAnswer(question, e),
                  ),
                )
                .toList(),
          )
        ]);
      },
    );
  }
}

class AnswerCard extends StatelessWidget {
  final String answer;
  final bool isSelected;
  final bool isCorrect;
  final bool isDisplayingAnswer;
  final VoidCallback onTap;

  const AnswerCard(
      {Key? key,
      required this.answer,
      required this.isSelected,
      required this.isCorrect,
      required this.isDisplayingAnswer,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
            margin: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 20.0,
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 20.0,
            ),
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: boxshadow,
                border: Border.all(
                  color: isDisplayingAnswer
                      ? isCorrect
                          ? Colors.green
                          : isSelected
                              ? Colors.red
                              : Colors.white
                      : Colors.white,
                  width: 4.0,
                ),
                borderRadius: BorderRadius.circular(100)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                    child: Text(HtmlCharacterEntities.decode(answer),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: isDisplayingAnswer && isCorrect
                              ? FontWeight.bold
                              : FontWeight.w400,
                        ))),
                if (isDisplayingAnswer)
                  isCorrect
                      ? const CircularIcon(
                          icon: Icons.check, color: Colors.green)
                      : isSelected
                          ? const CircularIcon(
                              icon: Icons.close,
                              color: Colors.red,
                            )
                          : const SizedBox.shrink()
              ],
            )));
  }
}

class CircularIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const CircularIcon({
    Key? key,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24.0,
      width: 24.0,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: boxshadow,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 16,
      ),
    );
  }
}
