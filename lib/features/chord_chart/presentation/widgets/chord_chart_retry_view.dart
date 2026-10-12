import 'package:flutter/material.dart';
import 'package:key_starter/core/widgets/display_text.dart';

/// Message affiché entre la fin de la grille et sa reprise.
class ChordChartRetryView extends StatelessWidget {
  final int errorCount;

  const ChordChartRetryView({super.key, required this.errorCount});

  @override
  Widget build(BuildContext context) {
    final errorLabel = switch (errorCount) {
      0 => 'Sans erreur',
      1 => '1 erreur',
      _ => '$errorCount erreurs',
    };

    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: DisplayText('$errorLabel · on reprend'),
      ),
    );
  }
}
