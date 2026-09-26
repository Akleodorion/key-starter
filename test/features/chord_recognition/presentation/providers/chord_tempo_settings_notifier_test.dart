import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_exercise_settings_state.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/chord_tempo_settings_notifier.dart';

void main() {
  group('ChordTempoSettingsNotifier', () {
    group('build', () {
      test(
        'démarre en clé de Sol, 20 accords, avec l\'étendue de Flashcard Accords',
        () {
          //arrange
          final container = ProviderContainer();
          addTearDown(container.dispose);

          //act
          final settings = container.read(chordTempoSettingsProvider);

          //assert
          expect(
            settings,
            const NoteExerciseSettings(
              clef: ClefMode.treble,
              noteCount: 20,
              minNoteStep: 0,
              maxNoteStep: 10,
            ),
          );
        },
      );
    });
  });
}
