import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_chart.dart';
import 'package:key_starter/features/chord_chart/presentation/providers/chord_chart_play_notifier.dart';
import 'package:key_starter/features/chord_chart/presentation/providers/chord_chart_play_state.dart';
import 'package:key_starter/features/chord_chart/presentation/widgets/chord_chart_lines.dart';
import 'package:key_starter/features/chord_chart/presentation/widgets/chord_chart_retry_view.dart';

/// Jeu d'une grille en tempo Libre : la grille attend chaque case, puis le
/// message de reprise au bout de la grille.
class ChordChartFreePlayView extends ConsumerWidget {
  final ChordChart chart;

  const ChordChartFreePlayView({super.key, required this.chart});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(chordChartPlayProvider(chart))) {
      ChordChartPlayRunning(:final currentCellIndex, :final cellResults) =>
        ChordChartLines(
          chart: chart,
          currentCellIndex: currentCellIndex,
          cellResults: cellResults,
        ),
      ChordChartPlayRetrying(:final errorCount) => ChordChartRetryView(
        errorCount: errorCount,
      ),
    };
  }
}
