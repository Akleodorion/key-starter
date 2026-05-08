import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';
import 'package:key_starter/features/session/domain/entities/session.dart';

/// Carte hero affichant le pourcentage de réussite et le ratio notes correctes.
/// La couleur (vert / rouge) dépend d'un seuil à 80 %.
class ResultsAccuracyCard extends StatelessWidget {
  final Session session;

  const ResultsAccuracyCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final result = session.result!;
    final accuracy = (result.accuracy * 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: accuracy >= 80 ? AppColors.okSoft : AppColors.errSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '$accuracy%',
            style: AppTextStyles.display(
              size: 64,
            ).copyWith(color: accuracy >= 80 ? AppColors.ok : AppColors.err),
          ),
          const SizedBox(height: 4),
          Text(
            '${result.correctCount} / ${result.totalNotes} notes correctes',
            style: AppTextStyles.ui(
              size: 15,
              color: accuracy >= 80 ? AppColors.ok : AppColors.err,
            ),
          ),
        ],
      ),
    );
  }
}
