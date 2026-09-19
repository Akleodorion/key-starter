import 'package:equatable/equatable.dart';
import 'package:key_starter/core/enums/note_state.dart';

sealed class ChordFlashcardExerciseState extends Equatable {
  const ChordFlashcardExerciseState();
}

class ChordFlashcardExerciseRunning extends ChordFlashcardExerciseState {
  final List<List<int>> chordSteps;
  final int currentIndex;
  final NoteState noteState;
  final List<int>? playedSteps;

  const ChordFlashcardExerciseRunning({
    required this.chordSteps,
    required this.currentIndex,
    required this.noteState,
    this.playedSteps,
  });

  List<int> get currentChord => chordSteps[currentIndex];
  int get total => chordSteps.length;

  ChordFlashcardExerciseRunning copyWith({
    int? currentIndex,
    NoteState? noteState,
    List<int>? playedSteps,
  }) => ChordFlashcardExerciseRunning(
    chordSteps: chordSteps,
    currentIndex: currentIndex ?? this.currentIndex,
    noteState: noteState ?? this.noteState,
    playedSteps: playedSteps ?? this.playedSteps,
  );

  @override
  List<Object?> get props => [chordSteps, currentIndex, noteState, playedSteps];
}

class ChordFlashcardExerciseCompleted extends ChordFlashcardExerciseState {
  final int correctCount;
  final int totalNotes;
  final int avgResponseMs;
  final int bestStreak;

  const ChordFlashcardExerciseCompleted({
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
