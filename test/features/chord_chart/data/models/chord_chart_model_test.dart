import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/errors/exceptions.dart';
import 'package:key_starter/features/chord_chart/data/models/chord_chart_model.dart';
import 'package:key_starter/features/chord_chart/domain/entities/accidental.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_chart.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_chart_bar.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_chart_cell.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_quality.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_symbol.dart';
import 'package:key_starter/features/chord_chart/domain/entities/note_letter.dart';
import 'package:key_starter/features/chord_chart/domain/entities/spelled_note.dart';

ChordChartBar wholeBar(NoteLetter root, ChordQuality quality) => ChordChartBar(
  cells: [
    ChordChartCell(
      chord: ChordSymbol(root: SpelledNote(root), quality: quality),
      beats: 4,
    ),
  ],
);

List<ChordSymbol> chordsOf(ChordChart chart) => [
  for (final cell in chart.cells) cell.chord,
];

Matcher throwsUnsupported(String reason) => throwsA(
  isA<UnsupportedChordChartException>().having(
    (exception) => exception.reason,
    'reason',
    reason,
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
          wholeBar(NoteLetter.c, ChordQuality.major),
          wholeBar(NoteLetter.g, ChordQuality.major),
          wholeBar(NoteLetter.a, ChordQuality.minor),
          wholeBar(NoteLetter.f, ChordQuality.major),
        ]);
      });

      test('enchaîne les mesures de plusieurs lignes', () {
        //arrange
        const text = 'mesure: 4\n|C |G |\n\n|Dm |E |\n';

        //act
        final sut = ChordChartModel.fromText(text, fallbackTitle: 'Essai');

        //assert
        expect(sut.bars, [
          wholeBar(NoteLetter.c, ChordQuality.major),
          wholeBar(NoteLetter.g, ChordQuality.major),
          wholeBar(NoteLetter.d, ChordQuality.minor),
          wholeBar(NoteLetter.e, ChordQuality.major),
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

      test('lit les dièses et les bémols, en gardant leur orthographe', () {
        //arrange
        const text = 'mesure: 4\n|F#m |F♯ |Bb |G♭ |\n';

        //act
        final sut = ChordChartModel.fromText(text, fallbackTitle: 'Essai');

        //assert
        expect(chordsOf(sut), const [
          ChordSymbol(
            root: SpelledNote(NoteLetter.f, Accidental.sharp),
            quality: ChordQuality.minor,
          ),
          ChordSymbol(
            root: SpelledNote(NoteLetter.f, Accidental.sharp),
            quality: ChordQuality.major,
          ),
          ChordSymbol(
            root: SpelledNote(NoteLetter.b, Accidental.flat),
            quality: ChordQuality.major,
          ),
          ChordSymbol(
            root: SpelledNote(NoteLetter.g, Accidental.flat),
            quality: ChordQuality.major,
          ),
        ]);
      });

      test('lit les suffixes de qualité', () {
        //arrange
        const text = 'mesure: 4\n|G7 |Am7 |Fmaj7 |Dsus2 |Esus4 |\n';

        //act
        final sut = ChordChartModel.fromText(text, fallbackTitle: 'Essai');

        //assert
        expect(chordsOf(sut), const [
          ChordSymbol(
            root: SpelledNote(NoteLetter.g),
            quality: ChordQuality.dominantSeventh,
          ),
          ChordSymbol(
            root: SpelledNote(NoteLetter.a),
            quality: ChordQuality.minorSeventh,
          ),
          ChordSymbol(
            root: SpelledNote(NoteLetter.f),
            quality: ChordQuality.majorSeventh,
          ),
          ChordSymbol(
            root: SpelledNote(NoteLetter.d),
            quality: ChordQuality.suspendedSecond,
          ),
          ChordSymbol(
            root: SpelledNote(NoteLetter.e),
            quality: ChordQuality.suspendedFourth,
          ),
        ]);
      });

      test('lit un renversement imposé', () {
        //arrange
        const text = 'mesure: 4\n|C(1) |G7(2) |\n';

        //act
        final sut = ChordChartModel.fromText(text, fallbackTitle: 'Essai');

        //assert
        expect(chordsOf(sut), const [
          ChordSymbol(
            root: SpelledNote(NoteLetter.c),
            quality: ChordQuality.major,
            inversion: 1,
          ),
          ChordSymbol(
            root: SpelledNote(NoteLetter.g),
            quality: ChordQuality.dominantSeventh,
            inversion: 2,
          ),
        ]);
      });

      test('lit une basse imposée, altérée ou non', () {
        //arrange
        const text = 'mesure: 4\n|D/F# |C/E |Am7/G♭ |\n';

        //act
        final sut = ChordChartModel.fromText(text, fallbackTitle: 'Essai');

        //assert
        expect(chordsOf(sut), const [
          ChordSymbol(
            root: SpelledNote(NoteLetter.d),
            quality: ChordQuality.major,
            bass: SpelledNote(NoteLetter.f, Accidental.sharp),
          ),
          ChordSymbol(
            root: SpelledNote(NoteLetter.c),
            quality: ChordQuality.major,
            bass: SpelledNote(NoteLetter.e),
          ),
          ChordSymbol(
            root: SpelledNote(NoteLetter.a),
            quality: ChordQuality.minorSeventh,
            bass: SpelledNote(NoteLetter.g, Accidental.flat),
          ),
        ]);
      });

      test('refuse un renversement autre que 1 ou 2', () {
        //arrange
        const text = 'mesure: 4\n|C(3) |\n';

        //act
        ChordChartModel parseText() =>
            ChordChartModel.fromText(text, fallbackTitle: 'Essai');

        //assert
        expect(parseText, throwsUnsupported('Accord inconnu : C(3).'));
      });

      test('refuse un accord à la fois renversé et à basse imposée', () {
        //arrange
        const text = 'mesure: 4\n|C(1)/E |\n';

        //act
        ChordChartModel parseText() =>
            ChordChartModel.fromText(text, fallbackTitle: 'Essai');

        //assert
        expect(
          parseText,
          throwsUnsupported(
            'Un accord ne peut pas être à la fois renversé et à basse '
            'imposée (« C(1)/E »).',
          ),
        );
      });

      test('lit la grille de démonstration du vocabulaire', () async {
        //arrange
        final text = await rootBundle.loadString(
          'assets/grids/vocabulaire.txt',
        );

        //act
        final sut = ChordChartModel.fromText(text, fallbackTitle: 'Essai');

        //assert
        expect(sut.title, 'Vocabulaire');
        expect(chordsOf(sut), const [
          ChordSymbol(
            root: SpelledNote(NoteLetter.c),
            quality: ChordQuality.major,
            bass: SpelledNote(NoteLetter.e),
          ),
          ChordSymbol(
            root: SpelledNote(NoteLetter.d),
            quality: ChordQuality.minorSeventh,
          ),
          ChordSymbol(
            root: SpelledNote(NoteLetter.g),
            quality: ChordQuality.dominantSeventh,
          ),
          ChordSymbol(
            root: SpelledNote(NoteLetter.c),
            quality: ChordQuality.majorSeventh,
          ),
          ChordSymbol(
            root: SpelledNote(NoteLetter.f, Accidental.sharp),
            quality: ChordQuality.minor,
          ),
          ChordSymbol(
            root: SpelledNote(NoteLetter.b, Accidental.flat),
            quality: ChordQuality.major,
          ),
          ChordSymbol(
            root: SpelledNote(NoteLetter.c),
            quality: ChordQuality.suspendedFourth,
          ),
          ChordSymbol(
            root: SpelledNote(NoteLetter.c),
            quality: ChordQuality.major,
            inversion: 2,
          ),
        ]);
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
}
