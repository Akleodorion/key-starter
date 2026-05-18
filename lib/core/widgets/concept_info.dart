import 'package:flutter/material.dart';
import 'package:key_starter/core/models/concept.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';

class ConceptInfo extends StatelessWidget {
  final Concept concept;

  const ConceptInfo({super.key, required this.concept});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);

    return Expanded(
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
    );
  }
}
