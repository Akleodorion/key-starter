import 'package:flutter/material.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_chart_bar.dart';
import 'package:key_starter/features/chord_chart/presentation/models/chord_chart_cell_status.dart';
import 'package:key_starter/features/chord_chart/presentation/widgets/chord_chart_bar_view.dart';

/// Une ligne de grille : [barsPerLine] emplacements de mesure de même largeur,
/// même sur une dernière ligne incomplète.
class ChordChartLine extends StatelessWidget {
  final List<ChordChartBar> bars;

  /// Indice, parmi toutes les cases de la grille, de la première case de
  /// chaque mesure de [bars].
  final List<int> firstCellIndexes;
  final int barsPerLine;
  final ChordChartCellStatus Function(int cellIndex) statusOf;

  const ChordChartLine({
    super.key,
    required this.bars,
    required this.firstCellIndexes,
    required this.barsPerLine,
    required this.statusOf,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var barIndex = 0; barIndex < barsPerLine; barIndex++)
          Expanded(
            child: barIndex < bars.length
                ? ChordChartBarView(
                    bar: bars[barIndex],
                    firstCellIndex: firstCellIndexes[barIndex],
                    statusOf: statusOf,
                  )
                : const SizedBox.shrink(),
          ),
      ],
    );
  }
}
