import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/features/chord_recognition/presentation/widgets/simple_chord_count_row.dart';

class SimpleChordSettingsCard extends StatelessWidget {
  const SimpleChordSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const SimpleChordCountRow(),
    );
  }
}
