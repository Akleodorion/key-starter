import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_exercise_settings_state.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/tempo_exercise_config.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/tempo_exercise_notifier.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/tempo_exercise_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // 60 BPM : un temps = 1 s, décompte de 4 s, note n à 4,5 s + n s,
  // fenêtre de ±250 ms.
  const config = TempoExerciseConfig(
    settings: NoteExerciseSettings(
      clef: ClefMode.treble,
      noteCount: 10,
      minNoteStep: 0,
      maxNoteStep: 6,
    ),
    bpm: 60,
  );

  Duration noteTime(int index) => Duration(milliseconds: 4500 + index * 1000);

  /// Lance l'exercice sur une horloge simulée et passe le conteneur au corps
  /// du test, qui fait avancer le temps avec [FakeAsync.elapse].
  void runExercise(
    void Function(FakeAsync async, ProviderContainer container) body,
  ) {
    fakeAsync((async) {
      final startTime = DateTime(2026, 9, 26);
      final container = ProviderContainer(
        overrides: [
          tempoExerciseProvider(config).overrideWith(
            () => TempoExerciseNotifier(
              config,
              now: () => startTime.add(async.elapsed),
            ),
          ),
        ],
      );
      container.listen(tempoExerciseProvider(config), (_, _) {});
      body(async, container);
      container.dispose();
      async.flushTimers();
    });
  }

  TempoExerciseState readState(ProviderContainer container) =>
      container.read(tempoExerciseProvider(config));

  TempoExerciseRunning readRunning(ProviderContainer container) =>
      readState(container) as TempoExerciseRunning;

  void elapseUntil(FakeAsync async, Duration target) =>
      async.elapse(target - async.elapsed);

  void playStep(ProviderContainer container, int step) => container
      .read(tempoExerciseProvider(config).notifier)
      .simulateMidi(midiFromDiatonicStep(step));

  void playNoteCorrectly(ProviderContainer container, int index) =>
      playStep(container, readRunning(container).noteSteps[index]);

  void playNoteWrongly(ProviderContainer container, int index) =>
      playStep(container, readRunning(container).noteSteps[index] + 1);

  group('TempoExerciseNotifier', () {
    group('build', () {
      test(
        'tire autant de notes que demandé, dans l\'étendue, sans résultat',
        () {
          runExercise((async, container) {
            //arrange
            //act
            final running = readRunning(container);

            //assert
            expect(running.noteSteps, hasLength(10));
            expect(
              running.noteSteps,
              everyElement(
                allOf(greaterThanOrEqualTo(0), lessThanOrEqualTo(6)),
              ),
            );
            expect(running.noteStates, everyElement(NoteState.idle));
          });
        },
      );
    });

    group('simulateMidi', () {
      test('valide la note jouée juste dans sa fenêtre', () {
        runExercise((async, container) {
          //arrange
          elapseUntil(async, noteTime(0) + const Duration(milliseconds: 100));

          //act
          playNoteCorrectly(container, 0);

          //assert
          expect(readRunning(container).noteStates[0], NoteState.correct);
        });
      });

      test('marque fausse une mauvaise note jouée dans la fenêtre', () {
        runExercise((async, container) {
          //arrange
          elapseUntil(async, noteTime(0));

          //act
          playNoteWrongly(container, 0);

          //assert
          expect(readRunning(container).noteStates[0], NoteState.wrong);
        });
      });

      test('marque fausse une touche noire jouée dans la fenêtre', () {
        runExercise((async, container) {
          //arrange
          elapseUntil(async, noteTime(0));
          const cSharpMidiNumber = 61;

          //act
          container
              .read(tempoExerciseProvider(config).notifier)
              .simulateMidi(cSharpMidiNumber);

          //assert
          expect(readRunning(container).noteStates[0], NoteState.wrong);
        });
      });

      test('garde le premier appui de la fenêtre, juste puis faux', () {
        runExercise((async, container) {
          //arrange
          elapseUntil(async, noteTime(0) - const Duration(milliseconds: 100));
          playNoteCorrectly(container, 0);
          elapseUntil(async, noteTime(0) + const Duration(milliseconds: 100));

          //act
          playNoteWrongly(container, 0);

          //assert
          expect(readRunning(container).noteStates[0], NoteState.correct);
        });
      });

      test('garde le premier appui de la fenêtre, faux puis juste', () {
        runExercise((async, container) {
          //arrange
          elapseUntil(async, noteTime(0) - const Duration(milliseconds: 100));
          playNoteWrongly(container, 0);
          elapseUntil(async, noteTime(0) + const Duration(milliseconds: 100));

          //act
          playNoteCorrectly(container, 0);

          //assert
          expect(readRunning(container).noteStates[0], NoteState.wrong);
        });
      });

      test(
        'compte un appui hors fenêtre comme une erreur sur la note ouverte la plus proche',
        () {
          runExercise((async, container) {
            //arrange
            elapseUntil(async, noteTime(0));
            playNoteCorrectly(container, 0);
            elapseUntil(async, noteTime(0) + const Duration(milliseconds: 400));

            //act
            playNoteCorrectly(container, 1);

            //assert
            final noteStates = readRunning(container).noteStates;
            expect(noteStates[0], NoteState.correct);
            expect(noteStates[1], NoteState.wrong);
          });
        },
      );

      test('ne rouvre pas une note close par un appui hors fenêtre', () {
        runExercise((async, container) {
          //arrange
          elapseUntil(async, noteTime(1) - const Duration(milliseconds: 400));
          playNoteCorrectly(container, 1);
          elapseUntil(async, noteTime(1));

          //act
          playNoteCorrectly(container, 1);

          //assert
          expect(readRunning(container).noteStates[1], NoteState.wrong);
        });
      });

      test('ignore les appuis pendant le décompte', () {
        runExercise((async, container) {
          //arrange
          elapseUntil(async, const Duration(milliseconds: 2000));

          //act
          playNoteWrongly(container, 0);

          //assert
          expect(
            readRunning(container).noteStates,
            everyElement(NoteState.idle),
          );
        });
      });
    });

    group('fenêtre qui se ferme', () {
      test('marque ratée une note sans appui dans sa fenêtre', () {
        runExercise((async, container) {
          //arrange
          //act
          elapseUntil(async, noteTime(0) + const Duration(milliseconds: 260));

          //assert
          final noteStates = readRunning(container).noteStates;
          expect(noteStates[0], NoteState.wrong);
          expect(noteStates[1], NoteState.idle);
        });
      });
    });

    group('currentTargetStep', () {
      test('vise la note dont la fenêtre est ouverte', () {
        runExercise((async, container) {
          //arrange
          elapseUntil(async, noteTime(2));

          //act
          final targetStep = container
              .read(tempoExerciseProvider(config).notifier)
              .currentTargetStep;

          //assert
          expect(targetStep, readRunning(container).noteSteps[2]);
        });
      });

      test('vise la prochaine note ouverte entre deux fenêtres', () {
        runExercise((async, container) {
          //arrange
          elapseUntil(async, noteTime(2) + const Duration(milliseconds: 500));

          //act
          final targetStep = container
              .read(tempoExerciseProvider(config).notifier)
              .currentTargetStep;

          //assert
          expect(targetStep, readRunning(container).noteSteps[3]);
        });
      });
    });

    group('fin de l\'exercice', () {
      test(
        'termine après la fenêtre de la dernière note, avec le retard moyen',
        () {
          runExercise((async, container) {
            //arrange
            const lateness = Duration(milliseconds: 40);

            //act
            for (var index = 0; index < 10; index++) {
              elapseUntil(async, noteTime(index) + lateness);
              playNoteCorrectly(container, index);
            }
            final stateBeforeWindowCloses = readState(container);
            elapseUntil(async, noteTime(9) + const Duration(milliseconds: 260));

            //assert
            expect(stateBeforeWindowCloses, isA<TempoExerciseRunning>());
            expect(
              readState(container),
              const TempoExerciseCompleted(
                correctCount: 10,
                totalNotes: 10,
                avgTimingOffsetMs: 40,
                bestStreak: 10,
              ),
            );
          });
        },
      );

      test('mesure une avance moyenne en négatif', () {
        runExercise((async, container) {
          //arrange
          const advance = Duration(milliseconds: 60);

          //act
          for (var index = 0; index < 10; index++) {
            elapseUntil(async, noteTime(index) - advance);
            playNoteCorrectly(container, index);
          }
          elapseUntil(async, noteTime(9) + const Duration(milliseconds: 260));

          //assert
          final completed = readState(container) as TempoExerciseCompleted;
          expect(completed.avgTimingOffsetMs, -60);
        });
      });

      test('n\'a pas d\'écart moyen si aucune note n\'est juste', () {
        runExercise((async, container) {
          //arrange
          //act
          elapseUntil(async, noteTime(9) + const Duration(milliseconds: 260));

          //assert
          expect(
            readState(container),
            const TempoExerciseCompleted(
              correctCount: 0,
              totalNotes: 10,
              avgTimingOffsetMs: null,
              bestStreak: 0,
            ),
          );
        });
      });

      test(
        'calcule l\'écart sur les notes justes seulement, et la meilleure série',
        () {
          runExercise((async, container) {
            //arrange
            const correctIndexes = {0, 1, 2, 5, 6};

            //act
            for (var index = 0; index < 10; index++) {
              elapseUntil(
                async,
                noteTime(index) + const Duration(milliseconds: 20),
              );
              if (correctIndexes.contains(index)) {
                playNoteCorrectly(container, index);
              } else if (index == 3) {
                playNoteWrongly(container, index);
              }
            }
            elapseUntil(async, noteTime(9) + const Duration(milliseconds: 260));

            //assert
            expect(
              readState(container),
              const TempoExerciseCompleted(
                correctCount: 5,
                totalNotes: 10,
                avgTimingOffsetMs: 20,
                bestStreak: 3,
              ),
            );
          });
        },
      );
    });

    group('dispose', () {
      test('ne plante pas si on quitte l\'exercice en cours de route', () {
        fakeAsync((async) {
          //arrange
          final container = ProviderContainer();
          container.listen(tempoExerciseProvider(config), (_, _) {});
          async.elapse(noteTime(1));

          //act
          container.dispose();
          async.elapse(const Duration(seconds: 20));

          //assert — le test échoue d'office si un minuteur touche un notifier détruit
        });
      });
    });
  });
}
