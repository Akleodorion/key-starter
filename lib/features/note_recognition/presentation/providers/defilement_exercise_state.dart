import 'package:equatable/equatable.dart';
import 'package:key_starter/core/enums/note_state.dart';

sealed class DefilementExerciseState extends Equatable {
  const DefilementExerciseState();
}

class DefilementExerciseRunning extends DefilementExerciseState {
  final List<int> noteSteps;
  final int currentIndex;
  final NoteState noteState;
  final int? playedStep;

  const DefilementExerciseRunning({
    required this.noteSteps,
    required this.currentIndex,
    required this.noteState,
    this.playedStep,
  });

  int get currentStep => noteSteps[currentIndex];
  int get total => noteSteps.length;

  DefilementExerciseRunning copyWith({
    int? currentIndex,
    NoteState? noteState,
    int? playedStep,
  }) => DefilementExerciseRunning(
    noteSteps: noteSteps,
    currentIndex: currentIndex ?? this.currentIndex,
    noteState: noteState ?? this.noteState,
    playedStep: playedStep ?? this.playedStep,
  );

  @override
  List<Object?> get props => [noteSteps, currentIndex, noteState, playedStep];
}

class DefilementExerciseCompleted extends DefilementExerciseState {
  final int correctCount;
  final int totalNotes;
  final int avgResponseMs;
  final int bestStreak;

  const DefilementExerciseCompleted({
    required this.correctCount,
    required this.totalNotes,
    required this.avgResponseMs,
    required this.bestStreak,
  });

  @override
  List<Object?> get props => [
    correctCount,
    totalNotes,
    avgResponseMs,
    bestStreak,
  ];
}
