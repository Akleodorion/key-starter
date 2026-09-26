import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/chord_tempo_exercise_config.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/chord_tempo_exercise_notifier.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/chord_tempo_exercise_state.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_exercise_settings_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // 60 BPM : un temps = 1 s, décompte de 4 s, accord n à 4,5 s + n s,
  // fenêtre de ±250 ms. Un accord est jugé 100 ms après sa première note.
  const config = ChordTempoExerciseConfig(
    settings: NoteExerciseSettings(
      clef: ClefMode.treble,
      noteCount: 10,
      minNoteStep: 0,
      maxNoteStep: 10,
    ),
    bpm: 60,
  );
  const detectionWindow = Duration(milliseconds: 100);

  Duration chordTime(int index) => Duration(milliseconds: 4500 + index * 1000);

  /// Lance l'exercice sur une horloge simulée et passe le conteneur au corps
  /// du test, qui fait avancer le temps avec [FakeAsync.elapse].
  void runExercise(
    void Function(FakeAsync async, ProviderContainer container) body,
  ) {
    fakeAsync((async) {
      final startTime = DateTime(2026, 9, 26);
      final container = ProviderContainer(
        overrides: [
          chordTempoExerciseProvider(config).overrideWith(
            () => ChordTempoExerciseNotifier(
              config,
              now: () => startTime.add(async.elapsed),
            ),
          ),
        ],
      );
      container.listen(chordTempoExerciseProvider(config), (_, _) {});
      body(async, container);
      container.dispose();
      async.flushTimers();
    });
  }

  ChordTempoExerciseState readState(ProviderContainer container) =>
      container.read(chordTempoExerciseProvider(config));

  ChordTempoExerciseRunning readRunning(ProviderContainer container) =>
      readState(container) as ChordTempoExerciseRunning;

  ChordTempoExerciseNotifier readNotifier(ProviderContainer container) =>
      container.read(chordTempoExerciseProvider(config).notifier);

  void elapseUntil(FakeAsync async, Duration target) =>
      async.elapse(target - async.elapsed);

  void playSteps(ProviderContainer container, List<int> steps) => readNotifier(
    container,
  ).simulateMidi(steps.map(midiFromDiatonicStep).toList());

  void playChordCorrectly(ProviderContainer container, int index) =>
      playSteps(container, readRunning(container).chordSteps[index]);

  void playChordWrongly(ProviderContainer container, int index) {
    final chord = readRunning(container).chordSteps[index];
    playSteps(container, [chord.first + 1, ...chord.skip(1)]);
  }

  group('ChordTempoExerciseNotifier', () {
    group('build', () {
      test('tire autant de triades que demandé, dans l\'étendue', () {
        runExercise((async, container) {
          //arrange
          //act
          final running = readRunning(container);

          //assert
          expect(running.chordSteps, hasLength(10));
          for (final chord in running.chordSteps) {
            final root = chord.first;
            expect(chord, [root, root + 2, root + 4]);
            expect(root, greaterThanOrEqualTo(0));
            expect(root + 4, lessThanOrEqualTo(10));
          }
          expect(running.chordStates, everyElement(NoteState.idle));
        });
      });
    });

    group('simulateMidi', () {
      test('valide l\'accord joué juste dans sa fenêtre', () {
        runExercise((async, container) {
          //arrange
          elapseUntil(async, chordTime(0) + const Duration(milliseconds: 50));

          //act
          playChordCorrectly(container, 0);
          async.elapse(detectionWindow);

          //assert
          expect(readRunning(container).chordStates[0], NoteState.correct);
        });
      });

      test('marque faux un mauvais accord joué dans la fenêtre', () {
        runExercise((async, container) {
          //arrange
          elapseUntil(async, chordTime(0));

          //act
          playChordWrongly(container, 0);
          async.elapse(detectionWindow);

          //assert
          expect(readRunning(container).chordStates[0], NoteState.wrong);
        });
      });

      test('marque faux un accord incomplet', () {
        runExercise((async, container) {
          //arrange
          elapseUntil(async, chordTime(0));
          final chord = readRunning(container).chordSteps[0];

          //act
          playSteps(container, chord.take(2).toList());
          async.elapse(detectionWindow);

          //assert
          expect(readRunning(container).chordStates[0], NoteState.wrong);
        });
      });

      test(
        'juge un accord commencé en fin de fenêtre sur sa première note',
        () {
          runExercise((async, container) {
            //arrange
            elapseUntil(
              async,
              chordTime(0) + const Duration(milliseconds: 220),
            );

            //act
            playChordCorrectly(container, 0);
            async.elapse(detectionWindow);

            //assert
            expect(readRunning(container).chordStates[0], NoteState.correct);
          });
        },
      );

      test('garde le premier accord de la fenêtre, juste puis faux', () {
        runExercise((async, container) {
          //arrange
          elapseUntil(async, chordTime(0) - const Duration(milliseconds: 200));
          playChordCorrectly(container, 0);
          async.elapse(detectionWindow);

          //act
          playChordWrongly(container, 0);
          async.elapse(detectionWindow);

          //assert
          expect(readRunning(container).chordStates[0], NoteState.correct);
        });
      });

      test(
        'compte un accord hors fenêtre comme une erreur sur le prochain accord ouvert',
        () {
          runExercise((async, container) {
            //arrange
            elapseUntil(
              async,
              chordTime(0) + const Duration(milliseconds: 500),
            );

            //act
            playChordCorrectly(container, 1);
            async.elapse(detectionWindow);

            //assert
            final chordStates = readRunning(container).chordStates;
            expect(chordStates[0], NoteState.wrong);
            expect(chordStates[1], NoteState.wrong);
          });
        },
      );

      test('ignore les accords joués pendant le décompte', () {
        runExercise((async, container) {
          //arrange
          elapseUntil(async, const Duration(seconds: 2));

          //act
          playChordCorrectly(container, 0);
          async.elapse(detectionWindow);

          //assert
          expect(
            readRunning(container).chordStates,
            everyElement(NoteState.idle),
          );
        });
      });
    });

    group('fenêtre qui se ferme', () {
      test('marque raté un accord sans appui dans sa fenêtre', () {
        runExercise((async, container) {
          //arrange
          //act
          elapseUntil(async, chordTime(0) + const Duration(milliseconds: 300));

          //assert
          expect(readRunning(container).chordStates[0], NoteState.wrong);
          expect(readRunning(container).chordStates[1], NoteState.idle);
        });
      });
    });

    group('currentTargetChord', () {
      test('vise l\'accord dont la fenêtre est ouverte', () {
        runExercise((async, container) {
          //arrange
          elapseUntil(async, chordTime(2));

          //act
          final target = readNotifier(container).currentTargetChord;

          //assert
          expect(target, readRunning(container).chordSteps[2]);
        });
      });
    });

    group('fin de l\'exercice', () {
      test(
        'termine à la fermeture de la dernière fenêtre, avec le retard moyen',
        () {
          runExercise((async, container) {
            //arrange
            for (var index = 0; index < 10; index++) {
              elapseUntil(
                async,
                chordTime(index) + const Duration(milliseconds: 100),
              );
              if (index.isEven) {
                playChordCorrectly(container, index);
              } else {
                playChordWrongly(container, index);
              }
              async.elapse(detectionWindow);
            }

            //act
            elapseUntil(
              async,
              chordTime(9) + const Duration(milliseconds: 300),
            );

            //assert
            final completed =
                readState(container) as ChordTempoExerciseCompleted;
            expect(completed.correctCount, 5);
            expect(completed.totalChords, 10);
            expect(completed.avgTimingOffsetMs, 100);
            expect(completed.bestStreak, 1);
          });
        },
      );

      test('n\'a pas d\'écart moyen si aucun accord n\'est juste', () {
        runExercise((async, container) {
          //arrange
          //act
          elapseUntil(async, chordTime(9) + const Duration(milliseconds: 300));

          //assert
          final completed = readState(container) as ChordTempoExerciseCompleted;
          expect(completed.correctCount, 0);
          expect(completed.avgTimingOffsetMs, isNull);
        });
      });
    });

    group('dispose', () {
      test('ne plante pas si on quitte l\'exercice en cours de route', () {
        fakeAsync((async) {
          //arrange
          final container = ProviderContainer();
          container.listen(chordTempoExerciseProvider(config), (_, _) {});
          async.elapse(chordTime(0));
          final running =
              container.read(chordTempoExerciseProvider(config))
                  as ChordTempoExerciseRunning;
          container
              .read(chordTempoExerciseProvider(config).notifier)
              .simulateMidi(
                running.chordSteps[0].map(midiFromDiatonicStep).toList(),
              );

          //act
          container.dispose();
          async.elapse(const Duration(seconds: 20));

          //assert — le test échoue d'office si un minuteur touche un notifier détruit
        });
      });
    });
  });
}
