import 'package:equatable/equatable.dart';
import 'package:key_starter/core/enums/note_state.dart';

sealed class SimpleNoteExerciseState extends Equatable {
  const SimpleNoteExerciseState();
}

class SimpleNoteExerciseRunning extends SimpleNoteExerciseState {
  final List<int> noteIndexes;
  final int currentIndex;
  final NoteState noteState;
  final int? playedMidiNumber;

  const SimpleNoteExerciseRunning({
    required this.noteIndexes,
    required this.currentIndex,
    required this.noteState,
    this.playedMidiNumber,
  });

  int get currentNoteIndex => noteIndexes[currentIndex];

  SimpleNoteExerciseRunning copyWith({
    int? currentIndex,
    NoteState? noteState,
    int? playedMidiNumber,
  }) => SimpleNoteExerciseRunning(
    noteIndexes: noteIndexes,
    currentIndex: currentIndex ?? this.currentIndex,
    noteState: noteState ?? this.noteState,
    playedMidiNumber: playedMidiNumber ?? this.playedMidiNumber,
  );

  @override
  List<Object?> get props => [
    noteIndexes,
    currentIndex,
    noteState,
    playedMidiNumber,
  ];
}

class SimpleNoteExerciseCompleted extends SimpleNoteExerciseState {
  final int correctCount;
  final int totalNotes;
  final int bestStreak;
  final int avgResponseMs;

  const SimpleNoteExerciseCompleted({
    required this.correctCount,
    required this.totalNotes,
    required this.bestStreak,
    required this.avgResponseMs,
  });

  @override
  List<Object?> get props => [
    correctCount,
    totalNotes,
    bestStreak,
    avgResponseMs,
  ];
}
