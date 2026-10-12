import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/errors/exceptions.dart';
import 'package:key_starter/core/errors/failures.dart';
import 'package:key_starter/features/chord_chart/data/datasources/chord_chart_asset_datasource.dart';
import 'package:key_starter/features/chord_chart/data/repositories/chord_chart_repository_impl.dart';
import 'package:key_starter/features/chord_chart/domain/entities/bundled_chord_chart.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_chart.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'chord_chart_repository_impl_test.mocks.dart';

@GenerateMocks([ChordChartAssetDataSource])
void main() {
  late MockChordChartAssetDataSource dataSource;
  late ChordChartRepositoryImpl sut;
  const bundledChordChart = BundledChordChart(
    title: 'Quatre accords',
    assetPath: 'assets/grids/quatre_accords.txt',
  );

  setUp(() {
    dataSource = MockChordChartAssetDataSource();
    sut = ChordChartRepositoryImpl(dataSource: dataSource);
  });

  group('ChordChartRepositoryImpl', () {
    group('loadChordChart', () {
      test('renvoie la grille lue, sous le titre de son fichier', () async {
        //arrange
        when(
          dataSource.loadChordChartText(bundledChordChart.assetPath),
        ).thenAnswer((_) async => 'mesure: 4\n|C |G |Am |F |\n');

        //act
        final result = await sut.loadChordChart(bundledChordChart);

        //assert
        final chart = result.getOrElse(() => throw StateError('échec'));
        expect(chart, isA<ChordChart>());
        expect(chart.title, 'Quatre accords');
        expect(chart.bars, hasLength(4));
      });

      test(
        'renvoie la raison du refus d\'une grille non prise en charge',
        () async {
          //arrange
          when(
            dataSource.loadChordChartText(bundledChordChart.assetPath),
          ).thenAnswer((_) async => 'mesure: 4\n|H |\n');

          //act
          final result = await sut.loadChordChart(bundledChordChart);

          //assert
          expect(
            result,
            const Left<Failure, ChordChart>(
              UnsupportedChordChartFailure('Accord inconnu : H.'),
            ),
          );
        },
      );

      test(
        'renvoie ChordChartFileFailure quand le fichier est illisible',
        () async {
          //arrange
          when(
            dataSource.loadChordChartText(bundledChordChart.assetPath),
          ).thenThrow(const ChordChartFileException());

          //act
          final result = await sut.loadChordChart(bundledChordChart);

          //assert
          expect(
            result,
            const Left<Failure, ChordChart>(ChordChartFileFailure()),
          );
        },
      );
    });

    group('listChordCharts', () {
      test(
        'liste les grilles sous leur titre, par ordre alphabétique',
        () async {
          //arrange
          when(dataSource.listChordChartAssetPaths()).thenAnswer(
            (_) async => ['assets/grids/zebre.txt', 'assets/grids/abeille.txt'],
          );
          when(
            dataSource.loadChordChartText('assets/grids/zebre.txt'),
          ).thenAnswer((_) async => 'titre: Ballade\nmesure: 4\n|C |\n');
          when(
            dataSource.loadChordChartText('assets/grids/abeille.txt'),
          ).thenAnswer((_) async => 'titre: Valse\nmesure: 4\n|C |\n');

          //act
          final result = await sut.listChordCharts();

          //assert
          final charts = result.getOrElse(() => throw StateError('échec'));
          expect(charts, const [
            BundledChordChart(
              title: 'Ballade',
              assetPath: 'assets/grids/zebre.txt',
            ),
            BundledChordChart(
              title: 'Valse',
              assetPath: 'assets/grids/abeille.txt',
            ),
          ]);
        },
      );

      test(
        'prend le nom du fichier quand la grille n\'a pas de titre ou est illisible',
        () async {
          //arrange
          when(dataSource.listChordChartAssetPaths()).thenAnswer(
            (_) async => [
              'assets/grids/local/sans_titre.txt',
              'assets/grids/abime.txt',
            ],
          );
          when(
            dataSource.loadChordChartText('assets/grids/local/sans_titre.txt'),
          ).thenAnswer((_) async => 'mesure: 4\n|C |\n');
          when(
            dataSource.loadChordChartText('assets/grids/abime.txt'),
          ).thenThrow(const ChordChartFileException());

          //act
          final result = await sut.listChordCharts();

          //assert
          final charts = result.getOrElse(() => throw StateError('échec'));
          expect(charts.map((chart) => chart.title), ['Abime', 'Sans titre']);
        },
      );

      test(
        'renvoie ChordChartFileFailure quand les fichiers ne peuvent pas être listés',
        () async {
          //arrange
          when(
            dataSource.listChordChartAssetPaths(),
          ).thenThrow(Exception('manifeste illisible'));

          //act
          final result = await sut.listChordCharts();

          //assert
          expect(
            result,
            const Left<Failure, List<BundledChordChart>>(
              ChordChartFileFailure(),
            ),
          );
        },
      );
    });
  });
}
