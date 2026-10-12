import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/features/chord_chart/domain/entities/accidental.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_quality.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_symbol.dart';
import 'package:key_starter/features/chord_chart/domain/entities/note_letter.dart';
import 'package:key_starter/features/chord_chart/domain/entities/spelled_note.dart';
import 'package:key_starter/features/chord_chart/presentation/judging/chord_attempt_tracker.dart';

const c2 = 36;
const d2 = 38;
const a2 = 45;
const bFlat2 = 46;
const c3 = 48;
const d3 = 50;
const e3 = 52;
const fSharp3 = 54;
const g3 = 55;
const a3 = 57;
const bFlat3 = 58;
const c4 = 60;
const cSharp4 = 61;
const d4 = 62;
const e4 = 64;
const f4 = 65;
const g4 = 67;
const bFlat4 = 70;
const c5 = 72;
const cSharp5 = 73;
const fSharp5 = 78;
const a5 = 81;

const cMajor = ChordSymbol(
  root: SpelledNote(NoteLetter.c),
  quality: ChordQuality.major,
);

const cMajorSecondInversion = ChordSymbol(
  root: SpelledNote(NoteLetter.c),
  quality: ChordQuality.major,
  inversion: 2,
);

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

    group('basse imposée', () {
      test('attend tant que Mi n\'est pas en bas sur C/E', () {
        //arrange
        const cOverE = ChordSymbol(
          root: SpelledNote(NoteLetter.c),
          quality: ChordQuality.major,
          bass: SpelledNote(NoteLetter.e),
        );
        final sut = ChordAttemptTracker(expected: cOverE);

        //act
        final outcome = pressAll(sut, [c3, e4, g4]);

        //assert
        expect(outcome, const ChordAttemptPending());
      });

      test('accepte la basse imposée, étrangère à l\'accord, sur C/D', () {
        //arrange
        const cOverD = ChordSymbol(
          root: SpelledNote(NoteLetter.c),
          quality: ChordQuality.major,
          bass: SpelledNote(NoteLetter.d),
        );
        final sut = ChordAttemptTracker(expected: cOverD);

        //act
        final outcome = pressAll(sut, [c4, e4, g4, d2]);

        //assert
        expect(outcome, const ChordAttemptCorrect());
      });
    });

    group('renversement imposé', () {
      test('est juste avec Do à la basse puis Sol-Do-Mi sur C(2)', () {
        //arrange
        final sut = ChordAttemptTracker(expected: cMajorSecondInversion);

        //act
        final outcome = pressAll(sut, [c2, g3, c4, e4]);

        //assert
        expect(outcome, const ChordAttemptCorrect());
      });

      test(
        'attend tant que Do-Mi-Sol est joué au-dessus de la basse sur C(2)',
        () {
          //arrange
          final sut = ChordAttemptTracker(expected: cMajorSecondInversion);

          //act
          final outcome = pressAll(sut, [c2, c4, e4, g4]);

          //assert
          expect(outcome, const ChordAttemptPending());
        },
      );

      test('attend sur C(2) quand la basse est doublée à l\'octave', () {
        //arrange
        final sut = ChordAttemptTracker(expected: cMajorSecondInversion);

        //act
        final outcome = pressAll(sut, [c2, c3, g3, c4, e4]);

        //assert
        expect(outcome, const ChordAttemptPending());
      });
    });

    group('accord de 4 notes', () {
      const aMinorSeventh = ChordSymbol(
        root: SpelledNote(NoteLetter.a),
        quality: ChordQuality.minorSeventh,
      );

      test('est juste avec La à la basse et Do-Mi-Sol à droite sur Am7', () {
        //arrange
        final sut = ChordAttemptTracker(expected: aMinorSeventh);

        //act
        final outcome = pressAll(sut, [a2, c4, e4, g4]);

        //assert
        expect(outcome, const ChordAttemptCorrect());
      });

      test('attend tant que la quinte Mi manque sur Am7', () {
        //arrange
        final sut = ChordAttemptTracker(expected: aMinorSeventh);

        //act
        final outcome = pressAll(sut, [a2, c4, g4]);

        //assert
        expect(outcome, const ChordAttemptPending());
      });
    });

    group('fondamentale altérée', () {
      const fSharpMinor = ChordSymbol(
        root: SpelledNote(NoteLetter.f, Accidental.sharp),
        quality: ChordQuality.minor,
      );
      const bFlatMajor = ChordSymbol(
        root: SpelledNote(NoteLetter.b, Accidental.flat),
        quality: ChordQuality.major,
      );

      test('est juste sur F#m dans une octave', () {
        //arrange
        final sut = ChordAttemptTracker(expected: fSharpMinor);

        //act
        final outcome = pressAll(sut, [fSharp3, a3, cSharp4]);

        //assert
        expect(outcome, const ChordAttemptCorrect());
      });

      test('est juste sur F#m dans une autre octave, avec doublure', () {
        //arrange
        final sut = ChordAttemptTracker(expected: fSharpMinor);

        //act
        final outcome = pressAll(sut, [fSharp3, cSharp5, fSharp5, a5]);

        //assert
        expect(outcome, const ChordAttemptCorrect());
      });

      test('est juste sur Bb dans une octave', () {
        //arrange
        final sut = ChordAttemptTracker(expected: bFlatMajor);

        //act
        final outcome = pressAll(sut, [bFlat2, d3, f4]);

        //assert
        expect(outcome, const ChordAttemptCorrect());
      });

      test('est juste sur Bb dans une autre octave, avec doublure', () {
        //arrange
        final sut = ChordAttemptTracker(expected: bFlatMajor);

        //act
        final outcome = pressAll(sut, [bFlat3, d4, f4, bFlat4]);

        //assert
        expect(outcome, const ChordAttemptCorrect());
      });

      test('est faux sur une note étrangère à Bb', () {
        //arrange
        final sut = ChordAttemptTracker(expected: bFlatMajor);

        //act
        final outcome = pressAll(sut, [bFlat2, d3, e4]);

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
