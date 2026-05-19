import 'package:flutter/material.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/core/widgets/ui_text.dart';

class ExerciseFeedbackRow extends StatelessWidget {
  final int? playedStep;
  final NoteState noteState;
  final NoteLanguage language;

  const ExerciseFeedbackRow({
    super.key,
    required this.playedStep,
    required this.noteState,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final playedStepValue = playedStep;
    if (playedStepValue == null) return const SizedBox.shrink();

    final colors = AppColorTheme.of(context);
    final noteColor = noteState == NoteState.correct
        ? AppColors.stateGreen
        : AppColors.stateRed;
    final stateLabel = noteState == NoteState.correct ? 'joué' : 'faux';
    final noteName = noteLabel(playedStepValue, language);

    return Row(
      children: [
        Icon(Icons.circle, size: 8, color: noteColor),
        const SizedBox(width: 6),
        UiText(noteName, size: 14, weight: FontWeight.w600, color: noteColor),
        UiText(' · $stateLabel · suivante…', size: 14, color: colors.text2),
      ],
    );
  }
}
