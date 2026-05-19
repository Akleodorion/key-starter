import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/widgets/midi_pill.dart';
import 'package:key_starter/core/widgets/primary_icon_button.dart';
import 'package:key_starter/core/widgets/ui_text.dart';

class ExerciseTopBar extends StatelessWidget {
  final String exerciseLabel;
  final int currentNumber;
  final int total;

  const ExerciseTopBar({
    super.key,
    required this.exerciseLabel,
    required this.currentNumber,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        PrimaryIconButton(
          icon: Icons.close_rounded,
          onTap: () => Navigator.of(context).pop(),
        ),
        UiText(
          '$exerciseLabel · $currentNumber / $total',
          size: 14,
          color: colors.text2,
        ),
        const MidiPill(),
      ],
    );
  }
}
