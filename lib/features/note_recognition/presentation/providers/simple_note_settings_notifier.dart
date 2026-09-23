import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_exercise_settings_notifier.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_exercise_settings_state.dart';

final simpleNoteSettingsProvider =
    NotifierProvider<SimpleNoteSettingsNotifier, NoteExerciseSettings>(
      SimpleNoteSettingsNotifier.new,
    );

/// Implémentation de [NoteExerciseSettingsNotifier] pour l'exercice Notes
/// simples, qui n'utilise que le nombre de notes (ni clé ni étendue).
class SimpleNoteSettingsNotifier extends NoteExerciseSettingsNotifier {
  @override
  NoteExerciseSettings build() => const NoteExerciseSettings(
    clef: ClefMode.treble,
    noteCount: 15,
    minNoteStep: 0,
    maxNoteStep: 6,
  );
}
