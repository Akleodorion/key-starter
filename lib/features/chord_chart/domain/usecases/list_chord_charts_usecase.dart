import 'package:dartz/dartz.dart';
import 'package:key_starter/core/errors/failures.dart';
import 'package:key_starter/features/chord_chart/domain/entities/bundled_chord_chart.dart';
import 'package:key_starter/features/chord_chart/domain/repositories/chord_chart_repository.dart';

/// Liste les grilles livrées avec l'app, triées par titre.
///
/// Contrat : renvoie la liste ou le [Failure] de
/// [ChordChartRepository.listChordCharts].
///
/// ```dart
/// final result = await ListChordChartsUseCase(repository: repository)();
/// ```
///
/// Voir aussi : [ChordChartRepository]
class ListChordChartsUseCase {
  final ChordChartRepository repository;

  ListChordChartsUseCase({required this.repository});

  Future<Either<Failure, List<BundledChordChart>>> call() =>
      repository.listChordCharts();
}
