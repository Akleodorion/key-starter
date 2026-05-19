import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/features/session/presentation/widgets/recap_stat_cell.dart';

class RecapStatsCard extends StatelessWidget {
  final int correctCount;
  final int totalNotes;
  final int avgResponseMs;
  final int bestStreak;

  const RecapStatsCard({
    super.key,
    required this.correctCount,
    required this.totalNotes,
    required this.avgResponseMs,
    required this.bestStreak,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);
    final accuracyPercent = (correctCount / totalNotes * 100).round().toString();
    final avgSeconds =
        (avgResponseMs / 1000).toStringAsFixed(1).replaceAll('.', ',');

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
              value: avgSeconds,
              unit: 's',
              label: 'TEMPS MOYEN',
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
}
