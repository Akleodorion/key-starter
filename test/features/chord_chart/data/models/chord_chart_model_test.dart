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

ChordChartCell cell(int rootPitchClass, ChordQuality quality, int beats) =>
    ChordChartCell(
      chord: ChordSymbol(rootPitchClass: rootPitchClass, quality: quality),
      beats: beats,
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

      test('partage une mesure à 4 temps entre deux accords', () {
        //arrange
        const text = 'mesure: 4\n|Am G |\n';

        //act
        final sut = ChordChartModel.fromText(text, fallbackTitle: 'Essai');

        //assert
        expect(sut.bars, [
          ChordChartBar(
            cells: [
              cell(9, ChordQuality.minor, 2),
              cell(7, ChordQuality.major, 2),
            ],
          ),
        ]);
      });

      test('prolonge l\'accord précédent d\'un temps par point', () {
        //arrange
        const text = 'mesure: 4\n|C . F G |\n';

        //act
        final sut = ChordChartModel.fromText(text, fallbackTitle: 'Essai');

        //assert
        expect(sut.bars, [
          ChordChartBar(
            cells: [
              cell(0, ChordQuality.major, 2),
              cell(5, ChordQuality.major, 1),
              cell(7, ChordQuality.major, 1),
            ],
          ),
        ]);
      });

      test('tient un accord sur toute une mesure à 3 temps', () {
        //arrange
        const text = 'mesure: 3\n|C . . |\n';

        //act
        final sut = ChordChartModel.fromText(text, fallbackTitle: 'Essai');

        //assert
        expect(sut.beatsPerBar, 3);
        expect(sut.bars, [
          ChordChartBar(cells: [cell(0, ChordQuality.major, 3)]),
        ]);
      });

      test('refuse deux accords sans point en mesure à 3 temps', () {
        //arrange
        const text = 'mesure: 3\n|Am F |\n';

        //act
        //assert
        expect(
          () => ChordChartModel.fromText(text, fallbackTitle: 'Essai'),
          throwsUnsupported(
            'Deux accords ne se partagent pas une mesure à 3 temps : '
            '« |Am . F| » ou « |Am F .| » au lieu de « |Am F| ».',
          ),
        );
      });

      test('refuse trois accords sans point en mesure à 4 temps', () {
        //arrange
        const text = 'mesure: 4\n|C G Am |\n';

        //act
        //assert
        expect(
          () => ChordChartModel.fromText(text, fallbackTitle: 'Essai'),
          throwsUnsupported(
            'La mesure « |C G Am| » compte 3 temps au lieu de 4 : '
            'un accord ou un « . » par temps, le « . » prolongeant '
            'l\'accord précédent.',
          ),
        );
      });

      test(
        'refuse une mesure dont le nombre de temps diffère de la mesure',
        () {
          //arrange
          const text = 'mesure: 4\n|C . |\n';

          //act
          //assert
          expect(
            () => ChordChartModel.fromText(text, fallbackTitle: 'Essai'),
            throwsUnsupported(
              'La mesure « |C .| » compte 2 temps au lieu de 4 : '
              'un accord ou un « . » par temps, le « . » prolongeant '
              'l\'accord précédent.',
            ),
          );
        },
      );

      test('refuse une mesure qui commence par un point', () {
        //arrange
        const text = 'mesure: 4\n|C |. G Am F |\n';

        //act
        //assert
        expect(
          () => ChordChartModel.fromText(text, fallbackTitle: 'Essai'),
          throwsUnsupported(
            'Une mesure ne peut pas commencer par « . » : il prolonge '
            'l\'accord précédent de la même mesure (« |. G Am F| »).',
          ),
        );
      });

      test('refuse une mesure qui n\'est ni à 3 ni à 4 temps', () {
        //arrange
        const text = 'mesure: 5\n|C |\n';

        //act
        //assert
        expect(
          () => ChordChartModel.fromText(text, fallbackTitle: 'Essai'),
          throwsUnsupported(
            'Seules les mesures à 3 ou 4 temps sont prises en charge '
            '(« mesure: 5 »).',
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
