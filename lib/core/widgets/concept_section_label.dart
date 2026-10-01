import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/widgets/label_text.dart';

/// Titre d'un groupe d'exercices sur la page d'un concept.
class ConceptSectionLabel extends StatelessWidget {
  final String title;

  const ConceptSectionLabel(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);
    return LabelText(title.toUpperCase(), color: colors.text3);
  }
}
