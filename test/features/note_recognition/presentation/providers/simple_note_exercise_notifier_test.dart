import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/simple_note_exercise_notifier.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/simple_note_exercise_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const noteCount = 10;
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    container.listen(simpleNoteExerciseProvider(noteCount), (_, _) {});
  });

  tearDown(() => container.dispose());

  SimpleNoteExerciseRunning readRunningState() =>
      container.read(simpleNoteExerciseProvider(noteCount))
          as SimpleNoteExerciseRunning;

  int midiInOctave(int pitchClass, int octave) =>
      (octave + 1) * 12 + pitchClass;

  Future<void> waitForNextNote() => Future<void>.delayed(
    SimpleNoteExerciseNotifier.feedbackDuration +
        const Duration(milliseconds: 100),
  );

  Future<void> answer({required bool correctly}) async {
    final expectedPitchClass = readRunningState().currentPitchClass;
    final playedPitchClass = correctly
        ? expectedPitchClass
        : (expectedPitchClass + 1) % 12;
    container
        .read(simpleNoteExerciseProvider(noteCount).notifier)
        .simulateMidi(midiInOctave(playedPitchClass, 4));
    await waitForNextNote();
  }

  group('SimpleNoteExerciseNotifier', () {
    group('build', () {
      test('ne tire jamais deux fois la même note de suite', () {
        //arrange
        const longNoteCount = 100;
        container.listen(simpleNoteExerciseProvider(longNoteCount), (_, _) {});

        //act
        final pitchClasses =
            (container.read(simpleNoteExerciseProvider(longNoteCount))
                    as SimpleNoteExerciseRunning)
                .pitchClasses;

        //assert
        for (var position = 1; position < pitchClasses.length; position++) {
          expect(
            pitchClasses[position],
            isNot(pitchClasses[position - 1]),
            reason: 'répétition aux positions ${position - 1} et $position',
          );
        }
      });

      test('ne tire que des touches blanches', () {
        //arrange
        const longNoteCount = 100;
        container.listen(simpleNoteExerciseProvider(longNoteCount), (_, _) {});

        //act
        final pitchClasses =
            (container.read(simpleNoteExerciseProvider(longNoteCount))
                    as SimpleNoteExerciseRunning)
                .pitchClasses;

        //assert
        expect(pitchClasses, everyElement(isIn(diatonicSemitones)));
      });
    });

    group('simulateMidi', () {
      test('compte juste la note attendue jouée dans une autre octave', () {
        //arrange
        final sut = container.read(
          simpleNoteExerciseProvider(noteCount).notifier,
        );
        final expectedPitchClass = readRunningState().currentPitchClass;

        //act
        sut.simulateMidi(midiInOctave(expectedPitchClass, 6));

        //assert
        expect(readRunningState().noteState, NoteState.correct);
      });

      test('compte faux une autre touche blanche', () {
        //arrange
        final sut = container.read(
          simpleNoteExerciseProvider(noteCount).notifier,
        );
        final expectedPitchClass = readRunningState().currentPitchClass;
        final otherPitchClass =
            diatonicSemitones[(diatonicSemitones.indexOf(expectedPitchClass) +
                    1) %
                7];

        //act
        sut.simulateMidi(midiInOctave(otherPitchClass, 4));

        //assert
        expect(readRunningState().noteState, NoteState.wrong);
      });

      test('compte faux une touche noire', () {
        //arrange
        final sut = container.read(
          simpleNoteExerciseProvider(noteCount).notifier,
        );
        const cSharp4MidiNumber = 61;

        //act
        sut.simulateMidi(cSharp4MidiNumber);

        //assert
        expect(readRunningState().noteState, NoteState.wrong);
      });

      test('mémorise la touche jouée pour le retour visuel', () {
        //arrange
        final sut = container.read(
          simpleNoteExerciseProvider(noteCount).notifier,
        );
        const cSharp4MidiNumber = 61;

        //act
        sut.simulateMidi(cSharp4MidiNumber);

        //assert
        expect(readRunningState().playedMidiNumber, cSharp4MidiNumber);
      });

      test('ignore une touche jouée pendant le retour visuel', () {
        //arrange
        final sut = container.read(
          simpleNoteExerciseProvider(noteCount).notifier,
        );
        final expectedPitchClass = readRunningState().currentPitchClass;
        final otherPitchClass =
            diatonicSemitones[(diatonicSemitones.indexOf(expectedPitchClass) +
                    1) %
                7];
        sut.simulateMidi(midiInOctave(expectedPitchClass, 4));

        //act
        sut.simulateMidi(midiInOctave(otherPitchClass, 4));

        //assert
        expect(readRunningState().noteState, NoteState.correct);
      });

      test('passe à la note suivante, en attente, après la réponse', () async {
        //arrange
        final sut = container.read(
          simpleNoteExerciseProvider(noteCount).notifier,
        );
        final expectedPitchClass = readRunningState().currentPitchClass;

        //act
        sut.simulateMidi(midiInOctave(expectedPitchClass, 4));
        await waitForNextNote();

        //assert
        final state = readRunningState();
        expect(state.currentIndex, 1);
        expect(state.noteState, NoteState.idle);
      });

      test('efface la touche jouée en passant à la note suivante', () async {
        //act
        await answer(correctly: false);

        //assert
        expect(readRunningState().playedMidiNumber, isNull);
      });

      test(
        'termine par un récap : bonnes réponses, total et meilleure série',
        () async {
          //arrange
          const answers = [
            true, true, true, true, false, //
            true, true, false, false, false,
          ];

          //act
          for (final isCorrectAnswer in answers) {
            await answer(correctly: isCorrectAnswer);
          }

          //assert
          final state = container.read(simpleNoteExerciseProvider(noteCount));
          expect(state, isA<SimpleNoteExerciseCompleted>());
          final completed = state as SimpleNoteExerciseCompleted;
          expect(completed.correctCount, 6);
          expect(completed.totalNotes, 10);
          expect(completed.bestStreak, 4);
        },
      );

      test(
        'calcule le temps de réponse moyen depuis l\'affichage de chaque note',
        () async {
          //arrange
          const twoNotes = 2;
          var currentTime = DateTime(2026);
          final clockContainer = ProviderContainer(
            overrides: [
              simpleNoteExerciseProvider(twoNotes).overrideWith(
                () => SimpleNoteExerciseNotifier(
                  twoNotes,
                  now: () => currentTime,
                ),
              ),
            ],
          );
          addTearDown(clockContainer.dispose);
          final provider = simpleNoteExerciseProvider(twoNotes);
          clockContainer.listen(provider, (_, _) {});
          final sut = clockContainer.read(provider.notifier);
          int currentNoteMidi() => midiInOctave(
            (clockContainer.read(provider) as SimpleNoteExerciseRunning)
                .currentPitchClass,
            4,
          );

          //act
          currentTime = currentTime.add(const Duration(milliseconds: 800));
          sut.simulateMidi(currentNoteMidi());
          await waitForNextNote();
          currentTime = currentTime.add(const Duration(milliseconds: 400));
          sut.simulateMidi(currentNoteMidi());
          await waitForNextNote();

          //assert
          final completed =
              clockContainer.read(provider) as SimpleNoteExerciseCompleted;
          expect(completed.avgResponseMs, 600);
        },
      );
    });
  });
}
