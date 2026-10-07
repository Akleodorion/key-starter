import 'package:flutter/material.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/core/widgets/secondary_icon_button.dart';
import 'package:key_starter/core/widgets/ui_text.dart';

class NoteStepperControl extends StatelessWidget {
  final String label;
  final int step;
  final NoteLanguage language;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const NoteStepperControl({
    super.key,
    required this.label,
    required this.step,
    required this.language,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UiText(label, size: 12, color: colors.text2),
        const SizedBox(height: 6),
        Row(
          children: [
            SecondaryIconButton(
              icon: Icons.remove_rounded,
              color: colors.text,
              onTap: onDecrement,
            ),
            const SizedBox(width: 10),
            UiText(
              noteLabel(step, language),
              size: 15,
              weight: FontWeight.w600,
              color: colors.text,
            ),
            const SizedBox(width: 10),
            SecondaryIconButton(
              icon: Icons.add_rounded,
              color: colors.text,
              onTap: onIncrement,
            ),
          ],
        ),
      ],
    );
  }
}
