import 'package:equatable/equatable.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_chart_cell.dart';

/// Une mesure de grille : ses cases dans l'ordre.
class ChordChartBar extends Equatable {
  final List<ChordChartCell> cells;

  const ChordChartBar({required this.cells});

  @override
  List<Object?> get props => [cells];
}
