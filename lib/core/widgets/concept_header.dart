import 'package:flutter/material.dart';
import 'package:key_starter/core/models/concept.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';

class ConceptHeader extends StatelessWidget {
  final Concept concept;

  const ConceptHeader({super.key, required this.concept});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = isDark ? concept.darkTintColor : concept.tintColor;

    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Icon(concept.icon, color: concept.color, size: 32),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                concept.title,
                style: AppTextStyles.display(size: 26, color: colors.text),
              ),
              const SizedBox(height: 4),
              Text(
                concept.description,
                style: AppTextStyles.ui(size: 14, color: colors.text2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
