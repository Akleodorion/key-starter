import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';

/// Une ligne de statistique avec icône, label et valeur.
class ResultStatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const ResultStatRow({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.inkMute),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTextStyles.ui(size: 15, color: AppColors.inkSoft),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.ui(size: 15, weight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
