import 'package:dartz/dartz.dart';
import 'package:key_starter/core/errors/exceptions.dart';
import 'package:key_starter/core/errors/failures.dart';
import 'package:key_starter/features/chord_chart/data/datasources/chord_chart_asset_datasource.dart';
import 'package:key_starter/features/chord_chart/data/models/chord_chart_model.dart';
import 'package:key_starter/features/chord_chart/domain/entities/bundled_chord_chart.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_chart.dart';
import 'package:key_starter/features/chord_chart/domain/repositories/chord_chart_repository.dart';

/// Implémentation de [ChordChartRepository] qui lit les grilles des assets.
class ChordChartRepositoryImpl implements ChordChartRepository {
  final ChordChartAssetDataSource dataSource;

  ChordChartRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<BundledChordChart>>> listChordCharts() async {
    try {
      final charts = [
        for (final assetPath in await dataSource.listChordChartAssetPaths())
          BundledChordChart(
            title: await _titleOf(assetPath) ?? _titleFromFileName(assetPath),
            assetPath: assetPath,
          ),
      ]..sort((first, second) => first.title.compareTo(second.title));
      return Right(charts);
    } catch (_) {
      return const Left(ChordChartFileFailure());
    }
  }

  @override
  Future<Either<Failure, ChordChart>> loadChordChart(
    BundledChordChart bundledChordChart,
  ) async {
    try {
      final text = await dataSource.loadChordChartText(
        bundledChordChart.assetPath,
      );
      return Right(
        ChordChartModel.fromText(text, fallbackTitle: bundledChordChart.title),
      );
    } on UnsupportedChordChartException catch (exception) {
      return Left(UnsupportedChordChartFailure(exception.reason));
    } on ChordChartFileException {
      return const Left(ChordChartFileFailure());
    }
  }

  Future<String?> _titleOf(String assetPath) async {
    try {
      return ChordChartModel.titleFromText(
        await dataSource.loadChordChartText(assetPath),
      );
    } on ChordChartFileException {
      return null;
    }
  }

  /// `assets/grids/sans_titre.txt` → « Sans titre ».
  String _titleFromFileName(String assetPath) {
    final words = assetPath
        .split('/')
        .last
        .replaceAll(RegExp(r'\.txt$'), '')
        .replaceAll('_', ' ');
    return words.isEmpty ? words : words[0].toUpperCase() + words.substring(1);
  }
}
