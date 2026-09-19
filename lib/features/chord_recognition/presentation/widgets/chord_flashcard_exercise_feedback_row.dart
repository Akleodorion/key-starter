import 'package:flutter/material.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/core/widgets/ui_text.dart';

/// Miroir de `ExerciseFeedbackRow` pour un groupe de notes (accord) au lieu
/// d'une seule note.
class ChordFlashcardExerciseFeedbackRow extends StatelessWidget {
  final List<int>? playedSteps;
  final NoteState noteState;
  final NoteLanguage language;

  const ChordFlashcardExerciseFeedbackRow({
    super.key,
    required this.playedSteps,
    required this.noteState,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final steps = playedSteps;
    if (steps == null || steps.isEmpty) return const SizedBox.shrink();

    final colors = AppColorTheme.of(context);
    final noteColor = noteState == NoteState.correct
        ? AppColors.stateGreen
        : AppColors.stateRed;
    final stateLabel = noteState == NoteState.correct ? 'joué' : 'faux';
    final chordName = steps
        .map((step) => noteLabel(step, language))
        .join(' · ');

    return Row(
      children: [
        Icon(Icons.circle, size: 8, color: noteColor),
        const SizedBox(width: 6),
        UiText(chordName, size: 14, weight: FontWeight.w600, color: noteColor),
        UiText(' · $stateLabel · suivant…', size: 14, color: colors.text2),
      ],
    );
  }
}
