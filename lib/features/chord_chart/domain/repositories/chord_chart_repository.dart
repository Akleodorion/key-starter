import 'package:dartz/dartz.dart';
import 'package:key_starter/core/errors/failures.dart';
import 'package:key_starter/features/chord_chart/domain/entities/bundled_chord_chart.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_chart.dart';

/// Accès aux grilles à travailler.
///
/// Contrat : [listChordCharts] renvoie les grilles livrées avec l'app,
/// triées par titre ; [loadChordChart] renvoie la grille lue, ou un
/// [Failure] — [UnsupportedChordChartFailure] (avec sa raison) si le fichier
/// contient un élément pas encore pris en charge, [ChordChartFileFailure] si
/// le fichier est illisible.
///
/// ```dart
/// final charts = await repository.listChordCharts();
/// final result = await repository.loadChordChart(bundledChordChart);
/// result.fold((failure) => ..., (chart) => ...);
/// ```
///
/// Voir aussi : [ChordChartRepositoryImpl]
abstract class ChordChartRepository {
  /// Grilles livrées, chacune sous le titre écrit dans son fichier.
  Future<Either<Failure, List<BundledChordChart>>> listChordCharts();

  /// Grille correspondant à [bundledChordChart].
  Future<Either<Failure, ChordChart>> loadChordChart(
    BundledChordChart bundledChordChart,
  );
}
