import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_exercise_settings_notifier.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_exercise_settings_state.dart';

final tempoSettingsProvider =
    NotifierProvider<TempoSettingsNotifier, NoteExerciseSettings>(
      TempoSettingsNotifier.new,
    );

/// Implémentation de [NoteExerciseSettingsNotifier] pour l'exercice Tempo.
class TempoSettingsNotifier extends NoteExerciseSettingsNotifier {
  @override
  NoteExerciseSettings build() => const NoteExerciseSettings(
    clef: ClefMode.treble,
    noteCount: 20,
    minNoteStep: -2,
    maxNoteStep: 4,
  );
}
