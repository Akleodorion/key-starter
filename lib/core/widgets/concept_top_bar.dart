import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/widgets/midi_pill.dart';
import 'package:key_starter/core/widgets/primary_icon_button.dart';
import 'package:key_starter/core/widgets/ui_text.dart';

class ConceptTopBar extends StatelessWidget {
  const ConceptTopBar({super.key, this.title});
  final String? title;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        PrimaryIconButton(
          icon: Icons.arrow_back_rounded,
          onTap: () => Navigator.of(context).pop(),
        ),
        if (title != null) UiText(title!, size: 14, color: colors.text2),
        const MidiPill(),
      ],
    );
  }
}
