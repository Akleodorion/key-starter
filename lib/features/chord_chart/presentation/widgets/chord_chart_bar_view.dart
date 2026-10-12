import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_chart_bar.dart';
import 'package:key_starter/features/chord_chart/presentation/models/chord_chart_cell_status.dart';
import 'package:key_starter/features/chord_chart/presentation/widgets/chord_chart_cell_view.dart';

/// Une mesure de grille : une barre de mesure à gauche, puis ses cases,
/// chacune large à proportion de sa durée.
class ChordChartBarView extends StatelessWidget {
  final ChordChartBar bar;

  /// Indice, parmi toutes les cases de la grille, de la première case de la
  /// mesure.
  final int firstCellIndex;
  final ChordChartCellStatus Function(int cellIndex) statusOf;

  const ChordChartBarView({
    super.key,
    required this.bar,
    required this.firstCellIndex,
    required this.statusOf,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: colors.text3, width: 2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < bar.cells.length; index++)
            Expanded(
              flex: bar.cells[index].beats,
              child: ChordChartCellView(
                cellIndex: firstCellIndex + index,
                chord: bar.cells[index].chord,
                status: statusOf(firstCellIndex + index),
              ),
            ),
        ],
      ),
    );
  }
}
