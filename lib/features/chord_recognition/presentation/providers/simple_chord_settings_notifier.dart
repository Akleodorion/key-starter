import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_exercise_settings_notifier.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_exercise_settings_state.dart';

final simpleChordSettingsProvider =
    NotifierProvider<SimpleChordSettingsNotifier, NoteExerciseSettings>(
      SimpleChordSettingsNotifier.new,
    );

/// Implémentation de [NoteExerciseSettingsNotifier] pour l'exercice Accords
/// simples, qui n'utilise que le nombre d'accords (ni clé ni étendue).
class SimpleChordSettingsNotifier extends NoteExerciseSettingsNotifier {
  @override
  NoteExerciseSettings build() => const NoteExerciseSettings(
    clef: ClefMode.treble,
    noteCount: 15,
    minNoteStep: 0,
    maxNoteStep: 6,
  );
}
