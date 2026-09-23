import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/simple_note_note_count_row.dart';

class SimpleNoteSettingsCard extends StatelessWidget {
  const SimpleNoteSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const SimpleNoteNoteCountRow(),
    );
  }
}
