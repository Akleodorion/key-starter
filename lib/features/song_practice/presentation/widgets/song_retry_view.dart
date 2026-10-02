import 'package:flutter/material.dart';
import 'package:key_starter/core/widgets/display_text.dart';

/// Message affiché entre la fin d'une section et sa reprise.
class SongRetryView extends StatelessWidget {
  final int errorCount;

  const SongRetryView({super.key, required this.errorCount});

  @override
  Widget build(BuildContext context) {
    final errorLabel = switch (errorCount) {
      0 => 'Sans erreur',
      1 => '1 erreur',
      _ => '$errorCount erreurs',
    };

    return Center(child: DisplayText('$errorLabel · on reprend'));
  }
}
