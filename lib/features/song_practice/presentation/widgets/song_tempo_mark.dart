import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/widgets/ui_text.dart';

/// Indication de tempo « ♩ = 60 », la noire dessinée avec la police Bravura.
class SongTempoMark extends StatelessWidget {
  /// Glyphe SMuFL metNoteQuarterUp.
  static const _quarterNoteGlyph = '';

  final int bpm;

  const SongTempoMark({super.key, required this.bpm});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _quarterNoteGlyph,
          style: TextStyle(
            fontFamily: 'Bravura',
            fontSize: 16,
            height: 1,
            color: colors.text2,
          ),
        ),
        const SizedBox(width: 4),
        UiText('= $bpm', size: 14, color: colors.text2),
      ],
    );
  }
}
