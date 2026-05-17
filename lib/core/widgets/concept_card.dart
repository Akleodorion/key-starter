import 'package:flutter/material.dart';
import 'package:key_starter/core/models/concept.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';
import 'package:key_starter/core/widgets/primary_icon_button.dart';

class ConceptCard extends StatelessWidget {
  final Concept concept;
  final VoidCallback? onTap;

  const ConceptCard({super.key, required this.concept, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = isDark ? concept.darkTintColor : concept.tintColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.line),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(concept.icon, color: concept.color, size: 24),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  concept.title,
                  style: AppTextStyles.ui(
                    size: 17,
                    weight: FontWeight.w700,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  concept.description,
                  style: AppTextStyles.ui(size: 13, color: colors.text2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          PrimaryIconButton(icon: Icons.chevron_right_rounded, onTap: onTap),
        ],
      ),
    );
  }
}
