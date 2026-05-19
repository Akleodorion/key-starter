import 'package:equatable/equatable.dart';
import 'package:key_starter/core/enums/note_state.dart';

sealed class FlashcardExerciseState extends Equatable {
  const FlashcardExerciseState();
}

class FlashcardExerciseRunning extends FlashcardExerciseState {
  final List<int> noteSteps;
  final int currentIndex;
  final NoteState noteState;
  final int? playedStep;

  const FlashcardExerciseRunning({
    required this.noteSteps,
    required this.currentIndex,
    required this.noteState,
    this.playedStep,
  });

  int get currentStep => noteSteps[currentIndex];
  int get total => noteSteps.length;

  FlashcardExerciseRunning copyWith({
    int? currentIndex,
    NoteState? noteState,
    int? playedStep,
  }) =>
      FlashcardExerciseRunning(
        noteSteps: noteSteps,
        currentIndex: currentIndex ?? this.currentIndex,
        noteState: noteState ?? this.noteState,
        playedStep: playedStep ?? this.playedStep,
      );

  @override
  List<Object?> get props => [noteSteps, currentIndex, noteState, playedStep];
}

class FlashcardExerciseCompleted extends FlashcardExerciseState {
  const FlashcardExerciseCompleted();

  @override
  List<Object?> get props => [];
}
