import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/tempo_bpm_row.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/tempo_clef_row.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/tempo_note_count_row.dart';

class TempoSettingsCard extends StatelessWidget {
  const TempoSettingsCard({super.key});

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
          const TempoClefRow(),
          divider,
          const TempoNoteCountRow(),
          divider,
          const TempoBpmRow(),
        ],
      ),
    );
  }
}
