import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/simple_chord_exercise_notifier.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/simple_chord_exercise_state.dart';

/// Triades diatoniques de Do majeur à l'état fondamental, octave 4 (Do4 = 60).
const _rootPositionChordsInOctave4 = [
  [60, 64, 67], // Do Mi Sol
  [62, 65, 69], // Ré Fa La
  [64, 67, 71], // Mi Sol Si
  [65, 69, 72], // Fa La Do
  [67, 71, 74], // Sol Si Ré
  [69, 72, 76], // La Do Mi
  [71, 74, 77], // Si Ré Fa
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const chordCount = 10;
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    container.listen(simpleChordExerciseProvider(chordCount), (_, _) {});
  });

  tearDown(() => container.dispose());

  SimpleChordExerciseRunning readRunningState() =>
      container.read(simpleChordExerciseProvider(chordCount))
          as SimpleChordExerciseRunning;

  List<int> expectedChordShiftedBy(int semitones) =>
      _rootPositionChordsInOctave4[readRunningState().currentRootIndex]
          .map((midiNumber) => midiNumber + semitones)
          .toList();

  Future<void> play(List<int> midiNumbers) async {
    container
        .read(simpleChordExerciseProvider(chordCount).notifier)
        .simulateMidi(midiNumbers);
    await Future<void>.delayed(const Duration(milliseconds: 150));
  }

  // Couvre la fenêtre de détection (100 ms) + le retour visuel + une marge.
  Future<void> waitForNextChord() => Future<void>.delayed(
    SimpleChordExerciseNotifier.feedbackDuration +
        const Duration(milliseconds: 250),
  );

  Future<void> answer({required bool correctly}) async {
    final rootIndex = readRunningState().currentRootIndex;
    final playedRootIndex = correctly ? rootIndex : (rootIndex + 1) % 7;
    await play(_rootPositionChordsInOctave4[playedRootIndex]);
    await waitForNextChord();
  }

  group('SimpleChordExerciseNotifier', () {
    group('build', () {
      test('ne tire jamais deux fois le même accord de suite', () {
        //arrange
        const longChordCount = 100;
        container.listen(
          simpleChordExerciseProvider(longChordCount),
          (_, _) {},
        );

        //act
        final rootIndexes =
            (container.read(simpleChordExerciseProvider(longChordCount))
                    as SimpleChordExerciseRunning)
                .rootIndexes;

        //assert
        for (var position = 1; position < rootIndexes.length; position++) {
          expect(
            rootIndexes[position],
            isNot(rootIndexes[position - 1]),
            reason: 'répétition aux positions ${position - 1} et $position',
          );
        }
      });
    });

    group('simulateMidi', () {
      test(
        'compte juste l\'accord attendu à l\'état fondamental, dans une autre octave',
        () async {
          //act
          await play(expectedChordShiftedBy(24));

          //assert
          expect(readRunningState().noteState, NoteState.correct);
        },
      );

      test('compte faux un accord étalé sur plusieurs octaves', () async {
        //arrange
        final chord = expectedChordShiftedBy(0);
        final spreadChord = [chord[0], chord[1] + 12, chord[2]];

        //act
        await play(spreadChord);

        //assert
        expect(readRunningState().noteState, NoteState.wrong);
      });

      test('compte faux un renversement', () async {
        //arrange
        final chord = expectedChordShiftedBy(0);
        final firstInversion = [chord[1], chord[2], chord[0] + 12];

        //act
        await play(firstInversion);

        //assert
        expect(readRunningState().noteState, NoteState.wrong);
      });

      test('compte faux l\'accord avec la fondamentale doublée', () async {
        //arrange
        final chord = expectedChordShiftedBy(0);

        //act
        await play([...chord, chord[0] + 12]);

        //assert
        expect(readRunningState().noteState, NoteState.wrong);
      });

      test('compte faux un autre accord', () async {
        //arrange
        final otherRootIndex = (readRunningState().currentRootIndex + 1) % 7;

        //act
        await play(_rootPositionChordsInOctave4[otherRootIndex]);

        //assert
        expect(readRunningState().noteState, NoteState.wrong);
      });

      test('compte faux un accord sur touches noires', () async {
        //arrange
        const cSharpMajorChord = [61, 65, 68];

        //act
        await play(cSharpMajorChord);

        //assert
        expect(readRunningState().noteState, NoteState.wrong);
      });

      test(
        'mémorise les touches jouées, de la plus grave à la plus aiguë',
        () async {
          //act
          await play([67, 60, 64]);

          //assert
          expect(readRunningState().playedMidiNumbers, [60, 64, 67]);
        },
      );

      test('ignore les touches jouées pendant le retour visuel', () async {
        //arrange
        final chord = expectedChordShiftedBy(0);
        await play(chord);

        //act
        await play([chord[0] + 1]);

        //assert
        expect(readRunningState().noteState, NoteState.correct);
      });

      test('passe à l\'accord suivant, en attente, après la réponse', () async {
        //act
        await play(expectedChordShiftedBy(0));
        await waitForNextChord();

        //assert
        final state = readRunningState();
        expect(state.currentIndex, 1);
        expect(state.noteState, NoteState.idle);
      });

      test(
        'efface les touches jouées en passant à l\'accord suivant',
        () async {
          //act
          await play(expectedChordShiftedBy(0));
          await waitForNextChord();

          //assert
          expect(readRunningState().playedMidiNumbers, isEmpty);
        },
      );

      test(
        'termine par un récap : bonnes réponses, total et meilleure série',
        () async {
          //arrange
          const answers = [
            true, false, true, true, true, //
            false, true, true, false, false,
          ];

          //act
          for (final isCorrectAnswer in answers) {
            await answer(correctly: isCorrectAnswer);
          }

          //assert
          final state = container.read(simpleChordExerciseProvider(chordCount));
          expect(state, isA<SimpleChordExerciseCompleted>());
          final completed = state as SimpleChordExerciseCompleted;
          expect(completed.correctCount, 6);
          expect(completed.totalChords, 10);
          expect(completed.bestStreak, 3);
        },
      );

      test(
        'calcule le temps de réponse moyen depuis l\'affichage de chaque accord',
        () async {
          //arrange
          const twoChords = 2;
          var currentTime = DateTime(2026);
          final clockContainer = ProviderContainer(
            overrides: [
              simpleChordExerciseProvider(twoChords).overrideWith(
                () => SimpleChordExerciseNotifier(
                  twoChords,
                  now: () => currentTime,
                ),
              ),
            ],
          );
          addTearDown(clockContainer.dispose);
          final provider = simpleChordExerciseProvider(twoChords);
          clockContainer.listen(provider, (_, _) {});
          final sut = clockContainer.read(provider.notifier);
          List<int> currentChord() =>
              _rootPositionChordsInOctave4[(clockContainer.read(provider)
                      as SimpleChordExerciseRunning)
                  .currentRootIndex];

          //act
          currentTime = currentTime.add(const Duration(milliseconds: 1000));
          sut.simulateMidi(currentChord());
          await waitForNextChord();
          currentTime = currentTime.add(const Duration(milliseconds: 600));
          sut.simulateMidi(currentChord());
          await waitForNextChord();

          //assert
          final completed =
              clockContainer.read(provider) as SimpleChordExerciseCompleted;
          expect(completed.avgResponseMs, 800);
        },
      );
    });
  });
}
