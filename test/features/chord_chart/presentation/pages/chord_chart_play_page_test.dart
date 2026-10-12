import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/errors/failures.dart';
import 'package:key_starter/core/input/input_source_kind.dart';
import 'package:key_starter/core/input/input_source_provider.dart';
import 'package:key_starter/core/providers/notation_language_provider.dart';
import 'package:key_starter/core/utils/note_feedback_motion.dart';
import 'package:key_starter/core/widgets/midi_only_entry_card.dart';
import 'package:key_starter/features/chord_chart/domain/entities/bundled_chord_chart.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_chart.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_chart_bar.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_chart_cell.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_quality.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_symbol.dart';
import 'package:key_starter/features/chord_chart/domain/entities/note_letter.dart';
import 'package:key_starter/features/chord_chart/domain/entities/spelled_note.dart';
import 'package:key_starter/features/chord_chart/domain/repositories/chord_chart_repository.dart';
import 'package:key_starter/features/chord_chart/domain/usecases/list_chord_charts_usecase.dart';
import 'package:key_starter/features/chord_chart/domain/usecases/load_chord_chart_usecase.dart';
import 'package:key_starter/features/chord_chart/presentation/models/chord_chart_cell_status.dart';
import 'package:key_starter/features/chord_chart/presentation/pages/chord_chart_concept_page.dart';
import 'package:key_starter/features/chord_chart/presentation/pages/chord_chart_play_page.dart';
import 'package:key_starter/features/chord_chart/presentation/providers/chord_chart_play_notifier.dart';
import 'package:key_starter/features/chord_chart/presentation/providers/chord_chart_providers.dart';
import 'package:key_starter/features/chord_chart/presentation/widgets/chord_chart_cell_view.dart';

import '../../../../core/input/fake_input_source.dart';
import '../../../../helpers/layout_test_helpers.dart';

const c4 = 60;
const d4 = 62;
const e4 = 64;
const g4 = 67;

const bundledChordChart = BundledChordChart(
  title: 'Douze mesures',
  assetPath: 'assets/grids/douze_mesures.txt',
);

ChordChartBar wholeBar(NoteLetter root, ChordQuality quality) => ChordChartBar(
  cells: [
    ChordChartCell(
      chord: ChordSymbol(root: SpelledNote(root), quality: quality),
      beats: 4,
    ),
  ],
);

/// Trois lignes de quatre mesures ; Mi majeur n'apparaît qu'en mesure 9,
/// première de la troisième ligne.
final chart = ChordChart(
  title: 'Douze mesures',
  beatsPerBar: 4,
  bars: [
    for (var line = 0; line < 2; line++) ...[
      wholeBar(NoteLetter.c, ChordQuality.major),
      wholeBar(NoteLetter.g, ChordQuality.major),
      wholeBar(NoteLetter.a, ChordQuality.minor),
      wholeBar(NoteLetter.f, ChordQuality.major),
    ],
    wholeBar(NoteLetter.e, ChordQuality.major),
    wholeBar(NoteLetter.d, ChordQuality.minor),
    wholeBar(NoteLetter.g, ChordQuality.major),
    wholeBar(NoteLetter.c, ChordQuality.major),
  ],
);

/// [ChordChartRepository] qui liste [bundledChordChart] et renvoie
/// [loadResult] au chargement.
class _StubChordChartRepository implements ChordChartRepository {
  final Either<Failure, ChordChart> loadResult;

  _StubChordChartRepository(this.loadResult);

  @override
  Future<Either<Failure, List<BundledChordChart>>> listChordCharts() async =>
      const Right([bundledChordChart]);

  @override
  Future<Either<Failure, ChordChart>> loadChordChart(
    BundledChordChart bundledChordChart,
  ) async => loadResult;
}

class _FixedNotationLanguageNotifier extends NotationLanguageNotifier {
  final NoteLanguage language;

  _FixedNotationLanguageNotifier(this.language);

  @override
  NoteLanguage build() => language;
}

void main() {
  late FakeInputSource inputSource;

  List<Override> playOverrides({
    Either<Failure, ChordChart>? loadResult,
    NoteLanguage language = NoteLanguage.en,
    InputSourceKind inputSourceKind = InputSourceKind.midi,
  }) {
    inputSource = FakeInputSource();
    final repository = _StubChordChartRepository(loadResult ?? Right(chart));
    return [
      inputSourceProvider.overrideWithValue(inputSource),
      activeInputSourceKindProvider.overrideWithValue(inputSourceKind),
      notationLanguageProvider.overrideWith(
        () => _FixedNotationLanguageNotifier(language),
      ),
      listChordChartsUseCaseProvider.overrideWithValue(
        ListChordChartsUseCase(repository: repository),
      ),
      loadChordChartUseCaseProvider.overrideWithValue(
        LoadChordChartUseCase(repository: repository),
      ),
    ];
  }

  Future<void> pumpPlayPage(
    WidgetTester tester, {
    Either<Failure, ChordChart>? loadResult,
    NoteLanguage language = NoteLanguage.en,
  }) async {
    await pumpOnScreen(
      tester,
      const ChordChartPlayPage(bundledChordChart: bundledChordChart),
      screenSize: galaxyNote10Landscape,
      textScale: 1,
      overrides: playOverrides(loadResult: loadResult, language: language),
    );
    await tester.pumpAndSettle();
  }

  Future<void> playChord(WidgetTester tester, List<int> midiNumbers) async {
    midiNumbers.forEach(inputSource.play);
    midiNumbers.forEach(inputSource.release);
    await tester.pump();
    await tester.pump(noteAdvanceDelay);
    await tester.pumpAndSettle();
  }

  ChordChartCellView cellViewAt(WidgetTester tester, int cellIndex) => tester
      .widgetList<ChordChartCellView>(find.byType(ChordChartCellView))
      .firstWhere((cellView) => cellView.cellIndex == cellIndex);

  group('ChordChartPlayPage', () {
    testWidgets('affiche les accords en notation anglaise', (tester) async {
      //arrange
      //act
      await pumpPlayPage(tester);

      //assert
      expect(find.text('Am'), findsWidgets);
      expect(find.text('F'), findsWidgets);
    });

    testWidgets('affiche les accords en notation française', (tester) async {
      //arrange
      //act
      await pumpPlayPage(tester, language: NoteLanguage.fr);

      //assert
      expect(find.text('Lam'), findsWidgets);
      expect(find.text('Sol'), findsWidgets);
    });

    testWidgets('surligne la première case avant toute frappe', (tester) async {
      //arrange
      //act
      await pumpPlayPage(tester);

      //assert
      expect(cellViewAt(tester, 0).status, ChordChartCellStatus.current);
      expect(cellViewAt(tester, 1).status, ChordChartCellStatus.pending);
    });

    testWidgets('garde la case jouée verte ou rouge', (tester) async {
      //arrange
      await pumpPlayPage(tester);

      //act
      await playChord(tester, [c4, e4, g4]);
      await playChord(tester, [c4, d4]);

      //assert
      expect(cellViewAt(tester, 0).status, ChordChartCellStatus.correct);
      expect(cellViewAt(tester, 1).status, ChordChartCellStatus.wrong);
      expect(cellViewAt(tester, 2).status, ChordChartCellStatus.current);
    });

    testWidgets(
      'fait défiler la grille quand la case passe à la ligne suivante',
      (tester) async {
        //arrange
        await pumpPlayPage(tester);
        final thirdLineVisibleAtStart = find.text('E').evaluate().isNotEmpty;

        //act
        for (var cell = 0; cell < 4; cell++) {
          await playChord(tester, [c4, d4]);
        }

        //assert
        expect(thirdLineVisibleAtStart, isFalse);
        expect(find.text('E'), findsOneWidget);
      },
    );

    testWidgets('affiche la raison du refus d\'une grille', (tester) async {
      //arrange
      //act
      await pumpPlayPage(
        tester,
        loadResult: const Left(
          UnsupportedChordChartFailure('Accord inconnu : H7.'),
        ),
      );

      //assert
      expect(find.text('Accord inconnu : H7.'), findsOneWidget);
    });

    testWidgets('annonce la reprise avec le nombre d\'erreurs', (tester) async {
      //arrange
      await pumpPlayPage(tester);

      //act
      for (var cell = 0; cell < chart.cells.length; cell++) {
        midiNumbersFor(cell, isCorrect: cell != 0).forEach(inputSource.play);
        midiNumbersFor(cell, isCorrect: cell != 0).forEach(inputSource.release);
        await tester.pump();
        await tester.pump(noteAdvanceDelay);
      }
      await tester.pump();

      //assert
      expect(find.text('1 erreur · on reprend'), findsOneWidget);
      await tester.pump(chordChartRetryDelay);
      await tester.pumpAndSettle();
    });

    testWidgets('ouvre le jeu depuis la carte de la grille', (tester) async {
      //arrange
      await pumpOnScreen(
        tester,
        const ChordChartConceptPage(),
        textScale: 1,
        overrides: playOverrides(),
      );
      await tester.pumpAndSettle();

      //act
      await tester.tap(
        find.descendant(
          of: find.ancestor(
            of: find.text(bundledChordChart.title),
            matching: find.byType(MidiOnlyEntryCard),
          ),
          matching: find.byType(GestureDetector),
        ),
      );
      await tester.pumpAndSettle();

      //assert
      final playPage = tester.widget<ChordChartPlayPage>(
        find.byType(ChordChartPlayPage),
      );
      expect(playPage.bundledChordChart, bundledChordChart);
    });

    testNoOverflow(
      'affiche la grille en cours de jeu',
      () => const ChordChartPlayPage(bundledChordChart: bundledChordChart),
      overrides: () => playOverrides(language: NoteLanguage.fr),
      arrange: (tester) => tester.pumpAndSettle(),
    );

    testNoOverflow(
      'affiche la grille sans source d\'entrée',
      () => const ChordChartPlayPage(bundledChordChart: bundledChordChart),
      overrides: () => playOverrides(inputSourceKind: InputSourceKind.none),
      arrange: (tester) => tester.pumpAndSettle(),
    );

    testNoOverflow(
      'affiche le message de reprise',
      () => const ChordChartPlayPage(bundledChordChart: bundledChordChart),
      overrides: () => playOverrides(),
      arrange: (tester) async {
        await tester.pumpAndSettle();
        for (var cell = 0; cell < chart.cells.length; cell++) {
          [c4, d4].forEach(inputSource.play);
          [c4, d4].forEach(inputSource.release);
          await tester.pump();
          await tester.pump(noteAdvanceDelay);
        }
        await tester.pump();
      },
    );
  });
}

/// Notes d'une frappe sur la case [cell] de [chart] : son accord à l'état
/// fondamental au-dessus du Do 4 si [isCorrect], sinon Do-Ré.
List<int> midiNumbersFor(int cell, {required bool isCorrect}) {
  if (!isCorrect) return [c4, d4];
  final chord = chart.cells[cell].chord;
  return [
    for (final semitones in chord.quality.semitonesFromRoot)
      48 + chord.rootPitchClass + semitones,
  ];
}
