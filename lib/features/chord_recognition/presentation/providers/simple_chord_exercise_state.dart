import 'package:equatable/equatable.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/features/chord_recognition/domain/entities/chord_prompt.dart';

sealed class SimpleChordExerciseState extends Equatable {
  const SimpleChordExerciseState();
}

class SimpleChordExerciseRunning extends SimpleChordExerciseState {
  final List<ChordPrompt> chords;
  final int currentIndex;
  final NoteState noteState;
  final List<int> playedMidiNumbers;

  const SimpleChordExerciseRunning({
    required this.chords,
    required this.currentIndex,
    required this.noteState,
    this.playedMidiNumbers = const [],
  });

  ChordPrompt get currentChord => chords[currentIndex];

  SimpleChordExerciseRunning copyWith({
    int? currentIndex,
    NoteState? noteState,
    List<int>? playedMidiNumbers,
  }) => SimpleChordExerciseRunning(
    chords: chords,
    currentIndex: currentIndex ?? this.currentIndex,
    noteState: noteState ?? this.noteState,
    playedMidiNumbers: playedMidiNumbers ?? this.playedMidiNumbers,
  );

  @override
  List<Object?> get props => [
    chords,
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
