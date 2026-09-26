import 'package:equatable/equatable.dart';
import 'package:key_starter/core/enums/note_state.dart';

sealed class ChordTempoExerciseState extends Equatable {
  const ChordTempoExerciseState();
}

/// Partie en cours : la séquence d'accords et le résultat de chacun
/// ([NoteState.idle] tant que sa fenêtre n'a rien décidé).
class ChordTempoExerciseRunning extends ChordTempoExerciseState {
  final List<List<int>> chordSteps;
  final List<NoteState> chordStates;

  const ChordTempoExerciseRunning({
    required this.chordSteps,
    required this.chordStates,
  });

  int get total => chordSteps.length;

  ChordTempoExerciseRunning copyWith({List<NoteState>? chordStates}) =>
      ChordTempoExerciseRunning(
        chordSteps: chordSteps,
        chordStates: chordStates ?? this.chordStates,
      );

  @override
  List<Object?> get props => [chordSteps, chordStates];
}

/// Partie terminée. [avgTimingOffsetMs] est l'écart moyen au temps des
/// accords justes, mesuré sur leur première note (négatif en avance, positif
/// en retard), null si aucun n'est juste.
class ChordTempoExerciseCompleted extends ChordTempoExerciseState {
  final int correctCount;
  final int totalChords;
  final int? avgTimingOffsetMs;
  final int bestStreak;

  const ChordTempoExerciseCompleted({
    required this.correctCount,
    required this.totalChords,
    required this.avgTimingOffsetMs,
    required this.bestStreak,
  });

  @override
  List<Object?> get props => [
    correctCount,
    totalChords,
    avgTimingOffsetMs,
    bestStreak,
  ];
}
