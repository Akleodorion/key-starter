import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_exercise_settings_notifier.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_exercise_settings_state.dart';

final chordFlashcardSettingsProvider =
    NotifierProvider<ChordFlashcardSettingsNotifier, NoteExerciseSettings>(
      ChordFlashcardSettingsNotifier.new,
    );

/// Implémentation de [NoteExerciseSettingsNotifier] pour l'exercice
/// Accords/Flashcard. Étendue par défaut plus large que Notes/Flashcard :
/// une triade a besoin de 4 pas de marge au-dessus de la fondamentale.
class ChordFlashcardSettingsNotifier extends NoteExerciseSettingsNotifier {
  @override
  NoteExerciseSettings build() => const NoteExerciseSettings(
    clef: ClefMode.treble,
    noteCount: 15,
    minNoteStep: 0,
    maxNoteStep: 10,
  );
}
