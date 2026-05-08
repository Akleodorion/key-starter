import 'package:equatable/equatable.dart';
import 'package:key_starter/features/session/domain/entities/session.dart';

enum LessonAnswer { awaiting, correct, wrong }

sealed class LessonState extends Equatable {
  const LessonState();
}

class LessonInProgress extends LessonState {
  final Session session;
  final int currentStep;
  final LessonAnswer answer;
  final int currentIndex;
  final int correctCount;

  const LessonInProgress({
    required this.session,
    required this.currentStep,
    this.answer = LessonAnswer.awaiting,
    required this.currentIndex,
    this.correctCount = 0,
  });

  LessonInProgress copyWith({
    Session? session,
    int? currentStep,
    LessonAnswer? answer,
    int? currentIndex,
    int? correctCount,
  }) => LessonInProgress(
    session: session ?? this.session,
    currentStep: currentStep ?? this.currentStep,
    answer: answer ?? this.answer,
    currentIndex: currentIndex ?? this.currentIndex,
    correctCount: correctCount ?? this.correctCount,
  );

  @override
  List<Object?> get props => [
    session,
    currentStep,
    answer,
    currentIndex,
    correctCount,
  ];
}

class LessonCompleted extends LessonState {
  final Session completedSession;

  const LessonCompleted({required this.completedSession});

  @override
  List<Object?> get props => [completedSession];
}
