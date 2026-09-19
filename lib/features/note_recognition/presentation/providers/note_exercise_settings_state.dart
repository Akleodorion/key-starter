import 'package:equatable/equatable.dart';
import 'package:key_starter/core/enums/clef_mode.dart';

/// Réglages communs aux exercices de séquence de notes (Flashcard,
/// Défilement) : clé, nombre de notes et étendue diatonique.
class NoteExerciseSettings extends Equatable {
  final ClefMode clef;
  final int noteCount;
  final int minNoteStep;
  final int maxNoteStep;

  const NoteExerciseSettings({
    required this.clef,
    required this.noteCount,
    required this.minNoteStep,
    required this.maxNoteStep,
  });

  NoteExerciseSettings copyWith({
    ClefMode? clef,
    int? noteCount,
    int? minNoteStep,
    int? maxNoteStep,
  }) => NoteExerciseSettings(
    clef: clef ?? this.clef,
    noteCount: noteCount ?? this.noteCount,
    minNoteStep: minNoteStep ?? this.minNoteStep,
    maxNoteStep: maxNoteStep ?? this.maxNoteStep,
  );

  @override
  List<Object?> get props => [clef, noteCount, minNoteStep, maxNoteStep];
}
