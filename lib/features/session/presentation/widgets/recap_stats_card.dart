import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/features/session/domain/entities/timing_offset.dart';
import 'package:key_starter/features/session/presentation/widgets/recap_stat_cell.dart';

class RecapStatsCard extends StatelessWidget {
  final int correctCount;
  final int totalNotes;
  final int? avgResponseMs;
  final TimingOffset? timingOffset;
  final int bestStreak;

  /// Affiche l'écart au temps à la place du temps moyen quand [timingOffset]
  /// est fourni.
  const RecapStatsCard({
    super.key,
    required this.correctCount,
    required this.totalNotes,
    this.avgResponseMs,
    this.timingOffset,
    required this.bestStreak,
  }) : assert(
         (avgResponseMs == null) != (timingOffset == null),
         'fournir soit avgResponseMs, soit timingOffset',
       );

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);
    final accuracyPercent = (correctCount / totalNotes * 100)
        .round()
        .toString();
    final (middleValue, middleUnit, middleLabel) = _middleStat();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            RecapStatCell(
              value: accuracyPercent,
              unit: '%',
              label: 'RÉSULTAT',
              unitColor: AppColors.notesFg,
            ),
            VerticalDivider(color: colors.line, width: 1),
            RecapStatCell(
              value: middleValue,
              unit: middleUnit,
              label: middleLabel,
              unitColor: colors.text3,
            ),
            VerticalDivider(color: colors.line, width: 1),
            RecapStatCell(
              value: bestStreak.toString(),
              unit: '×',
              label: 'PLUS GRANDE STREAK',
              unitColor: colors.text3,
            ),
          ],
        ),
      ),
    );
  }

  (String, String, String) _middleStat() {
    final offset = timingOffset;
    if (offset == null) {
      final avgSeconds = (avgResponseMs! / 1000)
          .toStringAsFixed(1)
          .replaceAll('.', ',');
      return (avgSeconds, 's', 'TEMPS MOYEN');
    }
    final averageMs = offset.averageMs;
    if (averageMs == null) return ('—', '', 'ÉCART MOYEN');
    final label = switch (averageMs) {
      < 0 => 'AVANCE MOYENNE',
      > 0 => 'RETARD MOYEN',
      _ => 'ÉCART MOYEN',
    };
    return (averageMs.abs().toString(), 'ms', label);
  }
}
