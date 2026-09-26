import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/utils/note_feedback_motion.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/chord_flashcard_exercise_notifier.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/chord_flashcard_exercise_state.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_exercise_settings_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const settings = NoteExerciseSettings(
    clef: ClefMode.treble,
    noteCount: 10,
    minNoteStep: 0,
    maxNoteStep: 6,
  );

  group('ChordFlashcardExerciseNotifier', () {
    group('simulateMidi', () {
      test('passe à la suivante 150 ms après le retour visuel, pas avant', () {
        fakeAsync((async) {
          //arrange
          final container = ProviderContainer();
          addTearDown(container.dispose);
          container.listen(chordFlashcardExerciseProvider(settings), (_, _) {});
          final sut = container.read(
            chordFlashcardExerciseProvider(settings).notifier,
          );
          final running =
              container.read(chordFlashcardExerciseProvider(settings))
                  as ChordFlashcardExerciseRunning;
          sut.simulateMidi(
            running.currentChord.map(midiFromDiatonicStep).toList(),
          );
          async.elapse(const Duration(milliseconds: 100));

          //act
          async.elapse(noteAdvanceDelay - const Duration(milliseconds: 50));
          final stateDuringFeedback =
              container.read(chordFlashcardExerciseProvider(settings))
                  as ChordFlashcardExerciseRunning;
          async.elapse(const Duration(milliseconds: 50));
          final stateAfterFeedback =
              container.read(chordFlashcardExerciseProvider(settings))
                  as ChordFlashcardExerciseRunning;

          //assert
          expect(stateDuringFeedback.noteState, NoteState.correct);
          expect(stateAfterFeedback.noteState, NoteState.idle);
        });
      });

      test(
        'ne plante pas si on quitte l\'exercice pendant le retour visuel',
        () async {
          //arrange
          final container = ProviderContainer();
          container.listen(chordFlashcardExerciseProvider(settings), (_, _) {});
          final sut = container.read(
            chordFlashcardExerciseProvider(settings).notifier,
          );
          final running =
              container.read(chordFlashcardExerciseProvider(settings))
                  as ChordFlashcardExerciseRunning;
          sut.simulateMidi(
            running.currentChord.map(midiFromDiatonicStep).toList(),
          );
          await Future<void>.delayed(const Duration(milliseconds: 150));

          //act
          container.dispose();
          await Future<void>.delayed(const Duration(milliseconds: 300));

          //assert — le test échoue d'office si le délai touche un notifier détruit
        },
      );
    });
  });
}
