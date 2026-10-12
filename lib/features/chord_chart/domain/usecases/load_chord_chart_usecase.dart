import 'package:dartz/dartz.dart';
import 'package:key_starter/core/errors/failures.dart';
import 'package:key_starter/features/chord_chart/domain/entities/bundled_chord_chart.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_chart.dart';
import 'package:key_starter/features/chord_chart/domain/repositories/chord_chart_repository.dart';

/// Charge une grille livrée avec l'app.
///
/// Contrat : renvoie la grille ou le [Failure] de
/// [ChordChartRepository.loadChordChart].
///
/// ```dart
/// final result = await LoadChordChartUseCase(repository: repository)(
///   bundledChordChart,
/// );
/// ```
///
/// Voir aussi : [ChordChartRepository]
class LoadChordChartUseCase {
  final ChordChartRepository repository;

  LoadChordChartUseCase({required this.repository});

  Future<Either<Failure, ChordChart>> call(
    BundledChordChart bundledChordChart,
  ) => repository.loadChordChart(bundledChordChart);
}
