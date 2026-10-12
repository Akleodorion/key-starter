import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/features/chord_chart/domain/entities/accidental.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_quality.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_symbol.dart';
import 'package:key_starter/features/chord_chart/domain/entities/note_letter.dart';
import 'package:key_starter/features/chord_chart/domain/entities/spelled_note.dart';

void main() {
  group('ChordSymbol', () {
    group('pitchClasses', () {
      test('donne les notes d\'un accord mineur', () {
        //arrange
        const sut = ChordSymbol(
          root: SpelledNote(NoteLetter.a),
          quality: ChordQuality.minor,
        );

        //act
        final pitchClasses = sut.pitchClasses;

        //assert
        expect(pitchClasses, {9, 0, 4});
      });

      test('part d\'une fondamentale dièse', () {
        //arrange
        const sut = ChordSymbol(
          root: SpelledNote(NoteLetter.f, Accidental.sharp),
          quality: ChordQuality.minor,
        );

        //act
        final pitchClasses = sut.pitchClasses;

        //assert
        expect(pitchClasses, {6, 9, 1});
      });

      test('part d\'une fondamentale bémol', () {
        //arrange
        const sut = ChordSymbol(
          root: SpelledNote(NoteLetter.b, Accidental.flat),
          quality: ChordQuality.major,
        );

        //act
        final pitchClasses = sut.pitchClasses;

        //assert
        expect(pitchClasses, {10, 2, 5});
      });

      final notesByQuality = {
        ChordQuality.major: [0, 4, 7],
        ChordQuality.minor: [0, 3, 7],
        ChordQuality.dominantSeventh: [0, 4, 7, 10],
        ChordQuality.minorSeventh: [0, 3, 7, 10],
        ChordQuality.majorSeventh: [0, 4, 7, 11],
        ChordQuality.suspendedSecond: [0, 2, 7],
        ChordQuality.suspendedFourth: [0, 5, 7],
      };
      for (final MapEntry(key: quality, value: expected)
          in notesByQuality.entries) {
        test('donne les notes d\'un accord de Do ${quality.name}', () {
          //arrange
          final sut = ChordSymbol(
            root: const SpelledNote(NoteLetter.c),
            quality: quality,
          );

          //act
          final pitchClasses = sut.pitchClasses;

          //assert
          expect(pitchClasses, expected.toSet());
        });
      }
    });

    group('bassPitchClass', () {
      test('attend la fondamentale sans basse imposée', () {
        //arrange
        const sut = ChordSymbol(
          root: SpelledNote(NoteLetter.d),
          quality: ChordQuality.major,
        );

        //act
        final bassPitchClass = sut.bassPitchClass;

        //assert
        expect(bassPitchClass, 2);
      });

      test('attend la basse imposée', () {
        //arrange
        const sut = ChordSymbol(
          root: SpelledNote(NoteLetter.d),
          quality: ChordQuality.major,
          bass: SpelledNote(NoteLetter.f, Accidental.sharp),
        );

        //act
        final bassPitchClass = sut.bassPitchClass;

        //assert
        expect(bassPitchClass, 6);
      });
    });

    group('inversionPitchClass', () {
      test('est null sans renversement imposé', () {
        //arrange
        const sut = ChordSymbol(
          root: SpelledNote(NoteLetter.c),
          quality: ChordQuality.major,
        );

        //act
        final inversionPitchClass = sut.inversionPitchClass;

        //assert
        expect(inversionPitchClass, isNull);
      });

      test('donne la deuxième note de l\'accord au premier renversement', () {
        //arrange
        const sut = ChordSymbol(
          root: SpelledNote(NoteLetter.c),
          quality: ChordQuality.suspendedSecond,
          inversion: 1,
        );

        //act
        final inversionPitchClass = sut.inversionPitchClass;

        //assert
        expect(inversionPitchClass, 2);
      });

      test('donne la troisième note de l\'accord au second renversement', () {
        //arrange
        const sut = ChordSymbol(
          root: SpelledNote(NoteLetter.g),
          quality: ChordQuality.dominantSeventh,
          inversion: 2,
        );

        //act
        final inversionPitchClass = sut.inversionPitchClass;

        //assert
        expect(inversionPitchClass, 2);
      });
    });

    group('constructeur', () {
      for (final inversion in [0, 3]) {
        test('refuse le renversement $inversion', () {
          //arrange
          const root = SpelledNote(NoteLetter.c);

          //act
          ChordSymbol buildChord() => ChordSymbol(
            root: root,
            quality: ChordQuality.major,
            inversion: inversion,
          );

          //assert
          expect(buildChord, throwsA(isA<AssertionError>()));
        });
      }

      for (final inversion in [1, 2]) {
        test('refuse le renversement $inversion avec une basse imposée', () {
          //arrange
          const root = SpelledNote(NoteLetter.c);
          const bass = SpelledNote(NoteLetter.e);

          //act
          ChordSymbol buildChord() => ChordSymbol(
            root: root,
            quality: ChordQuality.major,
            inversion: inversion,
            bass: bass,
          );

          //assert
          expect(buildChord, throwsA(isA<AssertionError>()));
        });
      }
    });
  });
}
