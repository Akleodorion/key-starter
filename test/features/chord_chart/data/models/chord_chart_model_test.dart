import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/errors/exceptions.dart';
import 'package:key_starter/features/chord_chart/data/models/chord_chart_model.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_chart_bar.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_chart_cell.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_quality.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_symbol.dart';

ChordChartBar wholeBar(int rootPitchClass, ChordQuality quality) =>
    ChordChartBar(
      cells: [
        ChordChartCell(
          chord: ChordSymbol(rootPitchClass: rootPitchClass, quality: quality),
          beats: 4,
        ),
      ],
    );

Matcher throwsUnsupported(String reason) => throwsA(
  isA<UnsupportedChordChartException>().having(
    (exception) => exception.reason,
    'reason',
    reason,
  ),
);

void main() {
  group('ChordChartModel', () {
    group('fromText', () {
      test('lit le titre, la mesure et un accord par mesure', () {
        //arrange
        const text = 'titre: Quatre accords\nmesure: 4\n|C |G |Am |F |\n';

        //act
        final sut = ChordChartModel.fromText(text, fallbackTitle: 'Essai');

        //assert
        expect(sut.title, 'Quatre accords');
        expect(sut.beatsPerBar, 4);
        expect(sut.bars, [
          wholeBar(0, ChordQuality.major),
          wholeBar(7, ChordQuality.major),
          wholeBar(9, ChordQuality.minor),
          wholeBar(5, ChordQuality.major),
        ]);
      });

      test('enchaîne les mesures de plusieurs lignes', () {
        //arrange
        const text = 'mesure: 4\n|C |G |\n\n|Dm |E |\n';

        //act
        final sut = ChordChartModel.fromText(text, fallbackTitle: 'Essai');

        //assert
        expect(sut.bars, [
          wholeBar(0, ChordQuality.major),
          wholeBar(7, ChordQuality.major),
          wholeBar(2, ChordQuality.minor),
          wholeBar(4, ChordQuality.major),
        ]);
      });

      test('prend le titre de repli quand le fichier n\'en a pas', () {
        //arrange
        const text = 'mesure: 4\n|C |\n';

        //act
        final sut = ChordChartModel.fromText(text, fallbackTitle: 'Essai');

        //assert
        expect(sut.title, 'Essai');
      });

      test('refuse un accord inconnu', () {
        //arrange
        const text = 'mesure: 4\n|C |H7 |\n';

        //act
        //assert
        expect(
          () => ChordChartModel.fromText(text, fallbackTitle: 'Essai'),
          throwsUnsupported('Accord inconnu : H7.'),
        );
      });

      test('refuse une mesure de plusieurs accords', () {
        //arrange
        const text = 'mesure: 4\n|Am G |\n';

        //act
        //assert
        expect(
          () => ChordChartModel.fromText(text, fallbackTitle: 'Essai'),
          throwsUnsupported(
            'Un seul accord par mesure pour l\'instant (« |Am G| »).',
          ),
        );
      });

      test('refuse une mesure qui n\'est pas à 4 temps', () {
        //arrange
        const text = 'mesure: 3\n|C |\n';

        //act
        //assert
        expect(
          () => ChordChartModel.fromText(text, fallbackTitle: 'Essai'),
          throwsUnsupported(
            'Seules les mesures à 4 temps sont prises en charge (« mesure: 3 »).',
          ),
        );
      });

      test('refuse une grille sans mesure indiquée', () {
        //arrange
        const text = '|C |\n';

        //act
        //assert
        expect(
          () => ChordChartModel.fromText(text, fallbackTitle: 'Essai'),
          throwsUnsupported(
            'La grille doit indiquer sa mesure (« mesure: 4 »).',
          ),
        );
      });

      test('refuse une grille sans aucune mesure', () {
        //arrange
        const text = 'titre: Vide\nmesure: 4\n';

        //act
        //assert
        expect(
          () => ChordChartModel.fromText(text, fallbackTitle: 'Essai'),
          throwsUnsupported('La grille ne contient aucune mesure.'),
        );
      });

      test('refuse une ligne illisible', () {
        //arrange
        const text = 'mesure: 4\nmotif: MG 1\n|C |\n';

        //act
        //assert
        expect(
          () => ChordChartModel.fromText(text, fallbackTitle: 'Essai'),
          throwsUnsupported('Ligne illisible : « motif: MG 1 ».'),
        );
      });
    });

    group('titleFromText', () {
      test('renvoie le titre écrit dans le fichier', () {
        //arrange
        const text = 'titre: Quatre accords\nmesure: 3\n|H |\n';

        //act
        final title = ChordChartModel.titleFromText(text);

        //assert
        expect(title, 'Quatre accords');
      });

      test('renvoie null quand le fichier n\'a pas de titre', () {
        //arrange
        const text = 'mesure: 4\n|C |\n';

        //act
        final title = ChordChartModel.titleFromText(text);

        //assert
        expect(title, isNull);
      });
    });
  });

  group('ChordSymbol', () {
    group('pitchClasses', () {
      test('donne les notes d\'un accord mineur', () {
        //arrange
        const sut = ChordSymbol(rootPitchClass: 9, quality: ChordQuality.minor);

        //act
        final pitchClasses = sut.pitchClasses;

        //assert
        expect(pitchClasses, {9, 0, 4});
      });
    });
  });
}
