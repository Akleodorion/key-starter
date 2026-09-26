import 'package:equatable/equatable.dart';
import 'package:key_starter/core/enums/note_state.dart';

sealed class TempoExerciseState extends Equatable {
  const TempoExerciseState();
}

/// Partie en cours : la séquence de notes et le résultat de chacune
/// ([NoteState.idle] tant que sa fenêtre n'a rien décidé).
class TempoExerciseRunning extends TempoExerciseState {
  final List<int> noteSteps;
  final List<NoteState> noteStates;

  const TempoExerciseRunning({
    required this.noteSteps,
    required this.noteStates,
  });

  int get total => noteSteps.length;

  TempoExerciseRunning copyWith({List<NoteState>? noteStates}) =>
      TempoExerciseRunning(
        noteSteps: noteSteps,
        noteStates: noteStates ?? this.noteStates,
      );

  @override
  List<Object?> get props => [noteSteps, noteStates];
}

/// Partie terminée. [avgTimingOffsetMs] est l'écart moyen au temps des notes
/// justes (négatif en avance, positif en retard), null si aucune n'est juste.
class TempoExerciseCompleted extends TempoExerciseState {
  final int correctCount;
  final int totalNotes;
  final int? avgTimingOffsetMs;
  final int bestStreak;

  const TempoExerciseCompleted({
    required this.correctCount,
    required this.totalNotes,
    required this.avgTimingOffsetMs,
    required this.bestStreak,
  });

  @override
  List<Object?> get props => [
    correctCount,
    totalNotes,
    avgTimingOffsetMs,
    bestStreak,
  ];
}
