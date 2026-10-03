import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/features/song_practice/domain/entities/note_value.dart';
import 'package:key_starter/features/song_practice/presentation/painting/song_glyphs.dart';

void main() {
  group('noteHeadGlyph', () {
    for (final (noteType, glyph) in [
      (NoteType.breve, ''),
      (NoteType.whole, ''),
      (NoteType.half, ''),
      (NoteType.quarter, ''),
      (NoteType.oneThousandTwentyFourth, ''),
    ]) {
      test('dessine la tête de $noteType', () {
        //arrange
        //act
        final sut = noteHeadGlyph(noteType);

        //assert
        expect(sut, glyph);
      });
    }
  });

  group('flagGlyph', () {
    for (final (noteType, stemUp, glyph) in [
      (NoteType.eighth, true, ''),
      (NoteType.eighth, false, ''),
      (NoteType.sixteenth, true, ''),
      (NoteType.oneThousandTwentyFourth, false, ''),
    ]) {
      test('dessine le crochet de $noteType, hampe en haut : $stemUp', () {
        //arrange
        //act
        final sut = flagGlyph(noteType, stemUp: stemUp);

        //assert
        expect(sut, glyph);
      });
    }

    test('ne dessine pas de crochet jusqu\'à la noire', () {
      //arrange
      //act
      final sut = flagGlyph(NoteType.quarter, stemUp: true);

      //assert
      expect(sut, isNull);
    });
  });

  group('restGlyph', () {
    for (final (noteType, glyph) in [
      (NoteType.breve, ''),
      (NoteType.whole, ''),
      (NoteType.half, ''),
      (NoteType.quarter, ''),
      (NoteType.eighth, ''),
      (NoteType.oneThousandTwentyFourth, ''),
    ]) {
      test('dessine le silence de $noteType', () {
        //arrange
        //act
        final sut = restGlyph(noteType);

        //assert
        expect(sut, glyph);
      });
    }
  });

  group('restBaselineLine', () {
    test('accroche la pause sous la 4e ligne', () {
      //arrange
      //act
      final sut = restBaselineLine(NoteType.whole);

      //assert
      expect(sut, 4);
    });

    test('pose les autres silences sur la ligne du milieu', () {
      //arrange
      //act
      final sut = restBaselineLine(NoteType.eighth);

      //assert
      expect(sut, 3);
    });
  });
}
