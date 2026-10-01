import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/utils/note_feedback_motion.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/defilement_exercise_notifier.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/defilement_exercise_state.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_exercise_settings_state.dart';
import 'package:key_starter/core/input/input_source_provider.dart';

import '../../../../core/input/fake_input_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const settings = NoteExerciseSettings(
    clef: ClefMode.treble,
    noteCount: 10,
    minNoteStep: 0,
    maxNoteStep: 6,
  );

  group('DefilementExerciseNotifier', () {
    group('simulateMidi', () {
      test('passe à la suivante 150 ms après le retour visuel, pas avant', () {
        fakeAsync((async) {
          //arrange
          final container = ProviderContainer();
          addTearDown(container.dispose);
          container.listen(defilementExerciseProvider(settings), (_, _) {});
          final sut = container.read(
            defilementExerciseProvider(settings).notifier,
          );
          final running =
              container.read(defilementExerciseProvider(settings))
                  as DefilementExerciseRunning;
          sut.simulateMidi(midiFromDiatonicStep(running.currentStep));
          //act
          async.elapse(noteAdvanceDelay - const Duration(milliseconds: 50));
          final stateDuringFeedback =
              container.read(defilementExerciseProvider(settings))
                  as DefilementExerciseRunning;
          async.elapse(const Duration(milliseconds: 50));
          final indexAfterFeedback =
              (container.read(defilementExerciseProvider(settings))
                      as DefilementExerciseRunning)
                  .currentIndex;

          //assert
          expect(stateDuringFeedback.noteState, NoteState.correct);
          expect(indexAfterFeedback, 1);
        });
      });

      test(
        'ne plante pas si on quitte l\'exercice pendant le retour visuel',
        () async {
          //arrange
          final container = ProviderContainer();
          container.listen(defilementExerciseProvider(settings), (_, _) {});
          final sut = container.read(
            defilementExerciseProvider(settings).notifier,
          );
          final running =
              container.read(defilementExerciseProvider(settings))
                  as DefilementExerciseRunning;
          sut.simulateMidi(midiFromDiatonicStep(running.currentStep));

          //act
          container.dispose();
          await Future<void>.delayed(const Duration(milliseconds: 300));

          //assert — le test échoue d'office si le délai touche un notifier détruit
        },
      );
    });
  });

  group('DefilementExerciseNotifier — source d\'entrée', () {
    const singleNoteSettings = NoteExerciseSettings(
      clef: ClefMode.treble,
      noteCount: 3,
      minNoteStep: 0,
      maxNoteStep: 0,
    );

    ProviderContainer containerWith(FakeInputSource inputSource) {
      final container = ProviderContainer(
        overrides: [inputSourceProvider.overrideWithValue(inputSource)],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('déclare la note exacte attendue comme cible', () {
      //arrange
      final inputSource = FakeInputSource();
      final container = containerWith(inputSource);

      //act
      container.listen(defilementExerciseProvider(settings), (_, _) {});
      final running =
          container.read(defilementExerciseProvider(settings))
              as DefilementExerciseRunning;

      //assert
      expect(inputSource.listenedTargets, [
        {midiFromDiatonicStep(running.currentStep)},
      ]);
    });

    test(
      'exige de relâcher la note avant de rejouer la même à l\'étape suivante',
      () {
        fakeAsync((async) {
          //arrange
          final inputSource = FakeInputSource();
          final container = containerWith(inputSource);
          container.listen(
            defilementExerciseProvider(singleNoteSettings),
            (_, _) {},
          );
          DefilementExerciseRunning readRunning() =>
              container.read(defilementExerciseProvider(singleNoteSettings))
                  as DefilementExerciseRunning;
          final doMidiNumber = midiFromDiatonicStep(0);
          inputSource.play(doMidiNumber);
          async.elapse(noteAdvanceDelay);

          //act
          inputSource.play(doMidiNumber);
          final stateWhileHeld = readRunning();
          inputSource.release(doMidiNumber);
          inputSource.play(doMidiNumber);
          final stateAfterRelease = readRunning();

          //assert
          expect(stateWhileHeld.currentIndex, 1);
          expect(stateWhileHeld.noteState, NoteState.idle);
          expect(stateAfterRelease.noteState, NoteState.correct);
        });
      },
    );

    test('mesure le temps de réponse jusqu\'à l\'attaque de la note', () {
      fakeAsync((async) {
        //arrange
        final inputSource = FakeInputSource();
        final container = containerWith(inputSource);
        container.listen(
          defilementExerciseProvider(singleNoteSettings),
          (_, _) {},
        );
        final doMidiNumber = midiFromDiatonicStep(0);
        const attackDelay = Duration(milliseconds: 1500);

        //act
        for (var index = 0; index < singleNoteSettings.noteCount; index++) {
          inputSource.play(
            doMidiNumber,
            attackTime: DateTime.now().add(attackDelay),
          );
          inputSource.release(doMidiNumber);
          async.elapse(noteAdvanceDelay);
        }
        final completed =
            container.read(defilementExerciseProvider(singleNoteSettings))
                as DefilementExerciseCompleted;

        //assert
        expect(completed.avgResponseMs, inInclusiveRange(1500, 1600));
      });
    });
  });
}
