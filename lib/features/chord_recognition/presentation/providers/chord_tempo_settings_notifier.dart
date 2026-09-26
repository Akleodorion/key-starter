import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_exercise_settings_notifier.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_exercise_settings_state.dart';

final chordTempoSettingsProvider =
    NotifierProvider<ChordTempoSettingsNotifier, NoteExerciseSettings>(
      ChordTempoSettingsNotifier.new,
    );

/// Implémentation de [NoteExerciseSettingsNotifier] pour l'exercice Tempo
/// Accords, avec l'étendue de Flashcard Accords (une triade a besoin de 4 pas
/// au-dessus de la fondamentale).
class ChordTempoSettingsNotifier extends NoteExerciseSettingsNotifier {
  @override
  NoteExerciseSettings build() => const NoteExerciseSettings(
    clef: ClefMode.treble,
    noteCount: 20,
    minNoteStep: 0,
    maxNoteStep: 10,
  );
}
