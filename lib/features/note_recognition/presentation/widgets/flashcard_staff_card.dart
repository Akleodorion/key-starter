import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/utils/staff_paint_utils.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_exercise_settings_state.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/flashcard_staff_widget.dart';

class FlashcardStaffCard extends StatelessWidget {
  static const double _verticalPadding = 24;

  final NoteExerciseSettings settings;

  const FlashcardStaffCard({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // La portée remplit la hauteur disponible ; sa largeur suit l'échelle
        // pour que le cadre épouse la portée au lieu de s'étirer.
        final lineGap = staffLineGapForHeight(
          constraints.maxHeight - _verticalPadding * 2,
        );

        return Center(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: _verticalPadding),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border.all(color: colors.line),
              borderRadius: BorderRadius.circular(20),
            ),
            child: FlashcardStaffWidget(
              settings: settings,
              height: lineGap * 10,
              staffwidth: lineGap * 16,
            ),
          ),
        );
      },
    );
  }
}
