import 'dart:math';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/input/input_source_provider.dart';
import 'package:key_starter/core/utils/note_feedback_motion.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/features/song_practice/presentation/providers/two_staff_flashcard_notifier.dart';
import 'package:key_starter/features/song_practice/presentation/providers/two_staff_flashcard_state.dart';

import '../../../../core/input/fake_input_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TwoStaffFlashcardNotifier', () {
    late FakeInputSource inputSource;
    late ProviderContainer container;

    // Appelé dans fakeAsync : le notifier doit naître dans la zone simulée
    // pour que ses timers suivent l'horloge du test.
    void startExercise() {
      inputSource = FakeInputSource();
      container = ProviderContainer(
        overrides: [inputSourceProvider.overrideWithValue(inputSource)],
      );
      addTearDown(container.dispose);
      container.listen(twoStaffFlashcardProvider, (_, _) {});
    }

    TwoStaffFlashcardRunning readState() =>
        container.read(twoStaffFlashcardProvider) as TwoStaffFlashcardRunning;

    List<int> expectedMidiNumbers(TwoStaffFlashcardRunning running) => [
      ...running.event.trebleSteps,
      ...running.event.bassSteps,
    ].map(midiFromDiatonicStep).toList();

    group('build', () {
      test('démarre sur un événement tiré, en attente de réponse', () {
        //arrange
        //act
        startExercise();
        final sut = readState();

        //assert
        expect(sut.event.trebleSteps, isNotEmpty);
        expect(sut.event.bassSteps, isNotEmpty);
        expect(sut.noteState, NoteState.idle);
        expect(sut.verdict, isNull);
      });
    });

    group('input', () {
      test(
        'juge juste dès que toutes les notes attendues sont tenues, et le reste tant qu\'elles sont tenues',
        () {
          fakeAsync((async) {
            //arrange
            startExercise();
            final initial = readState();

            //act
            expectedMidiNumbers(initial).forEach(inputSource.play);
            async.elapse(noteAdvanceDelay * 4);
            final sut = readState();

            //assert
            expect(sut.event, initial.event);
            expect(sut.noteState, NoteState.correct);
            expect(sut.verdict!.isCorrect, isTrue);
          });
        },
      );

      test(
        'passe à l\'événement suivant le délai standard après le relâchement de toutes les touches',
        () {
          fakeAsync((async) {
            //arrange
            startExercise();
            final midiNumbers = expectedMidiNumbers(readState());
            midiNumbers.forEach(inputSource.play);

            //act
            midiNumbers.forEach(inputSource.release);
            async.elapse(noteAdvanceDelay - const Duration(milliseconds: 1));
            final stateDuringFeedback = readState();
            async.elapse(const Duration(milliseconds: 1));
            final stateAfterFeedback = readState();

            //assert
            expect(stateDuringFeedback.noteState, NoteState.correct);
            expect(stateAfterFeedback.noteState, NoteState.idle);
            expect(stateAfterFeedback.verdict, isNull);
          });
        },
      );

      test(
        'juge faux avec le verdict par portée quand seule la clé de sol se trompe',
        () {
          fakeAsync((async) {
            //arrange
            startExercise();
            final event = readState().event;
            const c7MidiNumber = 96;
            final playedMidiNumbers = [
              c7MidiNumber,
              ...event.trebleSteps.skip(1).map(midiFromDiatonicStep),
              ...event.bassSteps.map(midiFromDiatonicStep),
            ];

            //act
            playedMidiNumbers.forEach(inputSource.play);
            final sut = readState();

            //assert
            expect(sut.noteState, NoteState.wrong);
            expect(sut.verdict!.treble.isCorrect, isFalse);
            expect(
              sut.verdict!.treble.playedMidiNumbers,
              contains(c7MidiNumber),
            );
            expect(sut.verdict!.bass.isCorrect, isTrue);
          });
        },
      );
    });
  });

  group('drawTwoStaffEvent', () {
    test(
      'tire la clé de sol entre Do 4 et Sol 5, la clé de fa entre Do 2 et Sol 3',
      () {
        //arrange
        final random = Random(42);

        //act
        final events = List.generate(200, (_) => drawTwoStaffEvent(random));

        //assert
        for (final event in events) {
          expect(event.trebleSteps, everyElement(inInclusiveRange(0, 11)));
          expect(event.bassSteps, everyElement(inInclusiveRange(-14, -3)));
        }
      },
    );

    test(
      'tire par portée une note seule ou un accord à l\'état fondamental, dans les quatre combinaisons',
      () {
        //arrange
        final random = Random(42);
        bool isRootPositionChord(List<int> steps) =>
            steps.length == 3 &&
            steps[1] == steps[0] + 2 &&
            steps[2] == steps[0] + 4;

        //act
        final events = List.generate(200, (_) => drawTwoStaffEvent(random));

        //assert
        for (final event in events) {
          for (final steps in [event.trebleSteps, event.bassSteps]) {
            expect(steps.length == 1 || isRootPositionChord(steps), isTrue);
          }
        }
        final combinations = events
            .map((event) => (event.trebleSteps.length, event.bassSteps.length))
            .toSet();
        expect(combinations, {(1, 1), (1, 3), (3, 1), (3, 3)});
      },
    );
  });
}
