import 'package:equatable/equatable.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_chart_bar.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_chart_cell.dart';

/// Une grille : son titre, son nombre de temps par mesure et ses mesures.
class ChordChart extends Equatable {
  final String title;
  final int beatsPerBar;
  final List<ChordChartBar> bars;

  const ChordChart({
    required this.title,
    required this.beatsPerBar,
    required this.bars,
  });

  /// Toutes les cases de la grille, mesure après mesure.
  List<ChordChartCell> get cells => [for (final bar in bars) ...bar.cells];

  @override
  List<Object?> get props => [title, beatsPerBar, bars];
}
