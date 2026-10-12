import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_quality.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_symbol.dart';
import 'package:key_starter/features/chord_chart/presentation/judging/chord_attempt_tracker.dart';

const c2 = 36;
const c3 = 48;
const e3 = 52;
const g3 = 55;
const c4 = 60;
const d4 = 62;
const e4 = 64;
const g4 = 67;
const c5 = 72;

const cMajor = ChordSymbol(rootPitchClass: 0, quality: ChordQuality.major);

ChordAttemptOutcome pressAll(ChordAttemptTracker sut, List<int> midiNumbers) {
  ChordAttemptOutcome outcome = const ChordAttemptPending();
  for (final midiNumber in midiNumbers) {
    outcome = sut.press(midiNumber);
  }
  return outcome;
}

void main() {
  group('ChordAttemptTracker', () {
    group('press', () {
      test('attend tant que l\'accord n\'est pas complet', () {
        //arrange
        final sut = ChordAttemptTracker(expected: cMajor);

        //act
        final outcome = pressAll(sut, [c4, e4]);

        //assert
        expect(outcome, const ChordAttemptPending());
      });

      test('est juste dès que Do-Mi-Sol sont tenus', () {
        //arrange
        final sut = ChordAttemptTracker(expected: cMajor);

        //act
        final outcome = pressAll(sut, [c4, e4, g4]);

        //assert
        expect(outcome, const ChordAttemptCorrect());
      });

      test('accepte un renversement à la main droite avec Do à la basse', () {
        //arrange
        final sut = ChordAttemptTracker(expected: cMajor);

        //act
        final outcome = pressAll(sut, [g3, c4, e4, c2]);

        //assert
        expect(outcome, const ChordAttemptCorrect());
      });

      test('accepte une autre octave et une doublure', () {
        //arrange
        final sut = ChordAttemptTracker(expected: cMajor);

        //act
        final outcome = pressAll(sut, [c3, e4, g4, c5]);

        //assert
        expect(outcome, const ChordAttemptCorrect());
      });

      test(
        'attend une basse plus grave quand la fondamentale n\'est pas en bas',
        () {
          //arrange
          final sut = ChordAttemptTracker(expected: cMajor);

          //act
          final outcome = pressAll(sut, [e3, g3, c4]);

          //assert
          expect(outcome, const ChordAttemptPending());
        },
      );

      test('est faux dès qu\'une note étrangère est jouée', () {
        //arrange
        final sut = ChordAttemptTracker(expected: cMajor);

        //act
        final outcome = pressAll(sut, [c4, d4]);

        //assert
        expect(outcome, const ChordAttemptWrong());
      });
    });

    group('release', () {
      test(
        'est faux quand tout est relâché avant que l\'accord soit complet',
        () {
          //arrange
          final sut = ChordAttemptTracker(expected: cMajor);
          pressAll(sut, [c4, e4]);
          sut.release(c4);

          //act
          final outcome = sut.release(e4);

          //assert
          expect(outcome, const ChordAttemptWrong());
        },
      );

      test('est faux quand tout est relâché sans la fondamentale en bas', () {
        //arrange
        final sut = ChordAttemptTracker(expected: cMajor);
        pressAll(sut, [e3, g3, c4]);
        sut.release(e3);
        sut.release(g3);

        //act
        final outcome = sut.release(c4);

        //assert
        expect(outcome, const ChordAttemptWrong());
      });

      test('laisse rejouer une note relâchée tant qu\'une autre est tenue', () {
        //arrange
        final sut = ChordAttemptTracker(expected: cMajor);
        pressAll(sut, [c4, e4]);
        sut.release(e4);

        //act
        final outcome = pressAll(sut, [e4, g4]);

        //assert
        expect(outcome, const ChordAttemptCorrect());
      });
    });

    group('touches déjà tenues', () {
      test('ignore une touche tenue depuis la case précédente', () {
        //arrange
        final sut = ChordAttemptTracker(expected: cMajor, alreadyHeld: {d4});

        //act
        final outcome = pressAll(sut, [c4, e4, g4]);

        //assert
        expect(outcome, const ChordAttemptCorrect());
      });

      test(
        'ne juge pas le relâchement d\'une touche tenue depuis la case précédente',
        () {
          //arrange
          final sut = ChordAttemptTracker(expected: cMajor, alreadyHeld: {d4});

          //act
          final outcome = sut.release(d4);

          //assert
          expect(outcome, const ChordAttemptPending());
        },
      );
    });
  });
}
