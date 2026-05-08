import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/features/session/domain/entities/session.dart';
import 'package:key_starter/features/session/presentation/widgets/result_stat_row.dart';

/// Liste des statistiques secondaires : durée, meilleure série et temps de
/// réponse moyen, chacune rendue via [ResultStatRow].
class ResultsStatsList extends StatelessWidget {
  final Session session;

  const ResultsStatsList({super.key, required this.session});

  String _formatDuration(int durationSec) {
    final minutes = durationSec ~/ 60;
    final seconds = durationSec % 60;
    return minutes > 0
        ? '${minutes}m ${seconds.toString().padLeft(2, '0')}s'
        : '${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final result = session.result!;

    return Column(
      children: [
        ResultStatRow(
          label: 'Durée',
          value: _formatDuration(result.durationSec),
          icon: Icons.timer_outlined,
        ),
        const Divider(height: 1, color: AppColors.line),
        ResultStatRow(
          label: 'Meilleure série',
          value: '${result.bestStreak} consécutives',
          icon: Icons.local_fire_department_outlined,
        ),
        const Divider(height: 1, color: AppColors.line),
        ResultStatRow(
          label: 'Temps de réponse moyen',
          value: '${result.avgResponseMs} ms',
          icon: Icons.speed_outlined,
        ),
      ],
    );
  }
}
