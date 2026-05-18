import 'package:flutter/material.dart';
import 'package:key_starter/core/models/card_entry.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/widgets/display_text.dart';
import 'package:key_starter/core/widgets/ui_text.dart';

class ConceptInfo extends StatelessWidget {
  final CardEntry concept;

  const ConceptInfo({super.key, required this.concept});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DisplayText(concept.title, size: 26, color: colors.text),
          const SizedBox(height: 4),
          UiText(concept.description, size: 14, color: colors.text2),
        ],
      ),
    );
  }
}
