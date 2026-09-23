import 'package:equatable/equatable.dart';
import 'package:key_starter/core/enums/note_state.dart';

sealed class SimpleChordExerciseState extends Equatable {
  const SimpleChordExerciseState();
}

class SimpleChordExerciseRunning extends SimpleChordExerciseState {
  final List<int> rootIndexes;
  final int currentIndex;
  final NoteState noteState;
  final List<int> playedMidiNumbers;

  const SimpleChordExerciseRunning({
    required this.rootIndexes,
    required this.currentIndex,
    required this.noteState,
    this.playedMidiNumbers = const [],
  });

  int get currentRootIndex => rootIndexes[currentIndex];

  SimpleChordExerciseRunning copyWith({
    int? currentIndex,
    NoteState? noteState,
    List<int>? playedMidiNumbers,
  }) => SimpleChordExerciseRunning(
    rootIndexes: rootIndexes,
    currentIndex: currentIndex ?? this.currentIndex,
    noteState: noteState ?? this.noteState,
    playedMidiNumbers: playedMidiNumbers ?? this.playedMidiNumbers,
  );

  @override
  List<Object?> get props => [
    rootIndexes,
    currentIndex,
    noteState,
    playedMidiNumbers,
  ];
}

class SimpleChordExerciseCompleted extends SimpleChordExerciseState {
  final int correctCount;
  final int totalChords;
  final int bestStreak;
  final int avgResponseMs;

  const SimpleChordExerciseCompleted({
    required this.correctCount,
    required this.totalChords,
    required this.bestStreak,
    required this.avgResponseMs,
  });

  @override
  List<Object?> get props => [
    correctCount,
    totalChords,
    bestStreak,
    avgResponseMs,
  ];
}
