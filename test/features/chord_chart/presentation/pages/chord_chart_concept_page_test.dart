import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/errors/failures.dart';
import 'package:key_starter/core/input/input_source_kind.dart';
import 'package:key_starter/core/input/input_source_provider.dart';
import 'package:key_starter/core/widgets/entry_card.dart';
import 'package:key_starter/features/chord_chart/domain/entities/bundled_chord_chart.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_chart.dart';
import 'package:key_starter/features/chord_chart/domain/repositories/chord_chart_repository.dart';
import 'package:key_starter/features/chord_chart/domain/usecases/list_chord_charts_usecase.dart';
import 'package:key_starter/features/chord_chart/presentation/pages/chord_chart_concept_page.dart';
import 'package:key_starter/features/chord_chart/presentation/providers/chord_chart_providers.dart';

import '../../../../core/input/fake_input_source.dart';
import '../../../../helpers/layout_test_helpers.dart';

const fourChords = BundledChordChart(
  title: 'Do Sol Lam Fa',
  assetPath: 'assets/grids/c_g_am_f.txt',
);
const letItBe = BundledChordChart(
  title: 'Let It Be, couplet et refrain avec renversements',
  assetPath: 'assets/grids/local/let_it_be.txt',
);

/// [ChordChartRepository] dont la liste est [charts], ou un échec si `null`.
class _StubChordChartRepository implements ChordChartRepository {
  final List<BundledChordChart>? charts;

  _StubChordChartRepository(this.charts);

  @override
  Future<Either<Failure, List<BundledChordChart>>> listChordCharts() async =>
      charts == null ? const Left(ChordChartFileFailure()) : Right(charts!);

  @override
  Future<Either<Failure, ChordChart>> loadChordChart(
    BundledChordChart bundledChordChart,
  ) async => const Left(ChordChartFileFailure());
}

List<Override> chartOverrides(List<BundledChordChart>? charts) => [
  inputSourceProvider.overrideWithValue(FakeInputSource()),
  activeInputSourceKindProvider.overrideWithValue(InputSourceKind.midi),
  listChordChartsUseCaseProvider.overrideWithValue(
    ListChordChartsUseCase(repository: _StubChordChartRepository(charts)),
  ),
];

void main() {
  group('ChordChartConceptPage', () {
    testWidgets('affiche une carte par grille, dans l\'ordre de la liste', (
      tester,
    ) async {
      //arrange
      await pumpOnScreen(
        tester,
        const ChordChartConceptPage(),
        textScale: 1,
        overrides: chartOverrides([fourChords, letItBe]),
      );

      //act
      await tester.pump();
      final titles = tester
          .widgetList<EntryCard>(find.byType(EntryCard))
          .map((card) => card.entry.title)
          .toList();

      //assert
      expect(titles, [fourChords.title, letItBe.title]);
    });

    testWidgets('dit quand les grilles ne peuvent pas être listées', (
      tester,
    ) async {
      //arrange
      await pumpOnScreen(
        tester,
        const ChordChartConceptPage(),
        textScale: 1,
        overrides: chartOverrides(null),
      );

      //act
      await tester.pump();

      //assert
      expect(find.text('Impossible de lister les grilles.'), findsOneWidget);
    });

    testNoOverflow(
      'affiche la liste des grilles',
      () => const ChordChartConceptPage(),
      overrides: () => chartOverrides([fourChords, letItBe]),
      arrange: (tester) => tester.pumpAndSettle(),
    );
  });
}
