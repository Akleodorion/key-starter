import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/widgets/concept_top_bar.dart';

class FlashcardPage extends StatelessWidget {
  const FlashcardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [const ConceptTopBar(title: 'Notes')],
          ),
        ),
      ),
    );
  }
}
