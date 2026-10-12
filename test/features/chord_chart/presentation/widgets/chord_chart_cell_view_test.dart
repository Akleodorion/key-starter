import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/features/chord_chart/domain/entities/accidental.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_quality.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_symbol.dart';
import 'package:key_starter/features/chord_chart/domain/entities/note_letter.dart';
import 'package:key_starter/features/chord_chart/domain/entities/spelled_note.dart';
import 'package:key_starter/features/chord_chart/presentation/widgets/chord_chart_cell_view.dart';

void main() {
  group('chordChartLabel', () {
    const naturalLetterLabels = [
      (NoteLetter.c, 'Do', 'C'),
      (NoteLetter.d, 'Ré', 'D'),
      (NoteLetter.e, 'Mi', 'E'),
      (NoteLetter.f, 'Fa', 'F'),
      (NoteLetter.g, 'Sol', 'G'),
      (NoteLetter.a, 'La', 'A'),
      (NoteLetter.b, 'Si', 'B'),
    ];
    for (final (letter, frenchLabel, englishLabel) in naturalLetterLabels) {
      test('nomme $letter « $frenchLabel » en notation Do et '
          '« $englishLabel » en notation C', () {
        //arrange
        final chord = ChordSymbol(
          root: SpelledNote(letter),
          quality: ChordQuality.major,
        );

        //act
        final frenchResult = chordChartLabel(chord, NoteLanguage.fr);
        final englishResult = chordChartLabel(chord, NoteLanguage.en);

        //assert
        expect(frenchResult, frenchLabel);
        expect(englishResult, englishLabel);
      });
    }

    const qualityLabels = [
      (ChordQuality.major, 'Do'),
      (ChordQuality.minor, 'Dom'),
      (ChordQuality.dominantSeventh, 'Do7'),
      (ChordQuality.minorSeventh, 'Dom7'),
      (ChordQuality.majorSeventh, 'Domaj7'),
      (ChordQuality.suspendedSecond, 'Dosus2'),
      (ChordQuality.suspendedFourth, 'Dosus4'),
    ];
    for (final (quality, expectedLabel) in qualityLabels) {
      test('nomme un accord $quality « $expectedLabel »', () {
        //arrange
        final chord = ChordSymbol(
          root: const SpelledNote(NoteLetter.c),
          quality: quality,
        );

        //act
        final result = chordChartLabel(chord, NoteLanguage.fr);

        //assert
        expect(result, expectedLabel);
      });
    }

    test('ajoute le renversement imposé entre parenthèses', () {
      //arrange
      const chord = ChordSymbol(
        root: SpelledNote(NoteLetter.a),
        quality: ChordQuality.minor,
        inversion: 1,
      );

      //act
      final result = chordChartLabel(chord, NoteLanguage.fr);

      //assert
      expect(result, 'Lam(1)');
    });

    test('ajoute une basse imposée altérée après une barre oblique', () {
      //arrange
      const chord = ChordSymbol(
        root: SpelledNote(NoteLetter.g),
        quality: ChordQuality.major,
        bass: SpelledNote(NoteLetter.f, Accidental.sharp),
      );

      //act
      final result = chordChartLabel(chord, NoteLanguage.fr);

      //assert
      expect(result, 'Sol/Fa♯');
    });

    test('nomme une fondamentale bémolisée avec ♭ en notation C', () {
      //arrange
      const chord = ChordSymbol(
        root: SpelledNote(NoteLetter.e, Accidental.flat),
        quality: ChordQuality.suspendedFourth,
      );

      //act
      final result = chordChartLabel(chord, NoteLanguage.en);

      //assert
      expect(result, 'E♭sus4');
    });
  });
}
