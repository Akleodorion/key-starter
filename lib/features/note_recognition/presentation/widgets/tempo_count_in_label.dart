import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/widgets/display_text.dart';

/// Décompte avant le départ de la barre (4, 3, 2, 1) ; rien quand [beat] est
/// null.
class TempoCountInLabel extends StatelessWidget {
  final int? beat;

  const TempoCountInLabel({super.key, required this.beat});

  @override
  Widget build(BuildContext context) {
    final currentBeat = beat;
    if (currentBeat == null) return const SizedBox.shrink();
    return DisplayText(
      currentBeat.toString(),
      size: 96,
      color: AppColors.notesFg,
    );
  }
}
