import 'package:flutter/material.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/core/widgets/ui_text.dart';

class SimpleNoteFeedbackRow extends StatelessWidget {
  final int? playedMidiNumber;
  final NoteState noteState;
  final NoteLanguage language;

  const SimpleNoteFeedbackRow({
    super.key,
    required this.playedMidiNumber,
    required this.noteState,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final playedMidiNumberValue = playedMidiNumber;
    if (playedMidiNumberValue == null) return const SizedBox.shrink();

    final colors = AppColorTheme.of(context);
    final isCorrect = noteState == NoteState.correct;
    final noteColor = isCorrect ? AppColors.stateGreen : AppColors.stateRed;
    final stateLabel = isCorrect ? 'joué' : 'faux';

    return Row(
      children: [
        Icon(Icons.circle, size: 8, color: noteColor),
        const SizedBox(width: 6),
        UiText(
          pitchClassLabel(playedMidiNumberValue, language),
          size: 14,
          weight: FontWeight.w600,
          color: noteColor,
        ),
        UiText(' · $stateLabel · suivante…', size: 14, color: colors.text2),
      ],
    );
  }
}
