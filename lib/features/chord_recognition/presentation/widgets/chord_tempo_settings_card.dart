import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/features/chord_recognition/presentation/widgets/chord_tempo_bpm_row.dart';
import 'package:key_starter/features/chord_recognition/presentation/widgets/chord_tempo_clef_row.dart';
import 'package:key_starter/features/chord_recognition/presentation/widgets/chord_tempo_chord_count_row.dart';

class ChordTempoSettingsCard extends StatelessWidget {
  const ChordTempoSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);
    final divider = Divider(height: 1, thickness: 1, color: colors.line);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const ChordTempoClefRow(),
          divider,
          const ChordTempoChordCountRow(),
          divider,
          const ChordTempoBpmRow(),
        ],
      ),
    );
  }
}
