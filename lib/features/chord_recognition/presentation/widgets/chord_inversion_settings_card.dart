import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/features/chord_recognition/presentation/widgets/chord_inversion_choice_row.dart';
import 'package:key_starter/features/chord_recognition/presentation/widgets/chord_inversion_count_row.dart';

class ChordInversionSettingsCard extends StatelessWidget {
  const ChordInversionSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const ChordInversionCountRow(),
          Divider(height: 1, thickness: 1, color: colors.line),
          const ChordInversionChoiceRow(),
        ],
      ),
    );
  }
}
