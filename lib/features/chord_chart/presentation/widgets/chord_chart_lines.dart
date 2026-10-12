import 'dart:math';

import 'package:flutter/material.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_chart.dart';
import 'package:key_starter/features/chord_chart/presentation/models/chord_chart_cell_status.dart';
import 'package:key_starter/features/chord_chart/presentation/widgets/chord_chart_line.dart';

/// Nombre de mesures par ligne de grille.
const chordChartBarsPerLine = 4;

const _visibleLineCount = 2;
const _scrollDuration = Duration(milliseconds: 300);

/// La grille, deux lignes visibles : celle de la case en cours en haut, la
/// suivante en dessous. Quand la case passe à la ligne suivante, les lignes
/// remontent : celle du haut s'efface et la nouvelle apparaît en bas.
class ChordChartLines extends StatelessWidget {
  final ChordChart chart;
  final int currentCellIndex;

  /// Résultat de chaque case déjà jouée (juste ou non), par indice de case.
  final Map<int, bool> cellResults;

  const ChordChartLines({
    super.key,
    required this.chart,
    required this.currentCellIndex,
    required this.cellResults,
  });

  @override
  Widget build(BuildContext context) {
    final firstCellIndexes = <int>[];
    var cellCount = 0;
    var currentBarIndex = 0;
    for (var barIndex = 0; barIndex < chart.bars.length; barIndex++) {
      firstCellIndexes.add(cellCount);
      cellCount += chart.bars[barIndex].cells.length;
      if (currentCellIndex >= firstCellIndexes.last) {
        currentBarIndex = barIndex;
      }
    }
    final lineCount = (chart.bars.length / chordChartBarsPerLine).ceil();
    final currentLineIndex = currentBarIndex ~/ chordChartBarsPerLine;

    return LayoutBuilder(
      builder: (context, constraints) {
        final lineHeight = constraints.maxHeight / _visibleLineCount;
        return ClipRect(
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: currentLineIndex.toDouble()),
            duration: _scrollDuration,
            curve: Curves.easeInOut,
            builder: (context, topLine, _) {
              final firstLine = topLine.floor();
              final lastLine = min(
                topLine.ceil() + _visibleLineCount - 1,
                lineCount - 1,
              );
              return Stack(
                children: [
                  for (
                    var lineIndex = firstLine;
                    lineIndex <= lastLine;
                    lineIndex++
                  )
                    Positioned(
                      key: ValueKey(lineIndex),
                      left: 0,
                      right: 0,
                      top: (lineIndex - topLine) * lineHeight,
                      height: lineHeight,
                      child: Opacity(
                        opacity: _opacityAt(lineIndex - topLine),
                        child: ChordChartLine(
                          bars: chart.bars
                              .skip(lineIndex * chordChartBarsPerLine)
                              .take(chordChartBarsPerLine)
                              .toList(),
                          firstCellIndexes: firstCellIndexes
                              .skip(lineIndex * chordChartBarsPerLine)
                              .take(chordChartBarsPerLine)
                              .toList(),
                          barsPerLine: chordChartBarsPerLine,
                          statusOf: _statusOf,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  ChordChartCellStatus _statusOf(int cellIndex) =>
      switch (cellResults[cellIndex]) {
        true => ChordChartCellStatus.correct,
        false => ChordChartCellStatus.wrong,
        null when cellIndex == currentCellIndex => ChordChartCellStatus.current,
        null => ChordChartCellStatus.pending,
      };

  /// Opacité selon la position de la ligne, en lignes depuis le haut : pleine
  /// sur les deux emplacements visibles, en fondu au-dessus et en dessous.
  double _opacityAt(double position) {
    if (position < 0) return (1 + position).clamp(0, 1);
    if (position > _visibleLineCount - 1) {
      return (_visibleLineCount - position).clamp(0, 1);
    }
    return 1;
  }
}
