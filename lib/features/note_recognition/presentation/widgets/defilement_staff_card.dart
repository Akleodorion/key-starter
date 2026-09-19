import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_exercise_settings_state.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/defilement_staff_widget.dart';

class DefilementStaffCard extends StatelessWidget {
  final NoteExerciseSettings settings;

  const DefilementStaffCard({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.line),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DefilementStaffWidget(settings: settings),
    );
  }
}
