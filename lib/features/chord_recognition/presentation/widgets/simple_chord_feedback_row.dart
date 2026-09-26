import 'package:flutter/material.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/core/widgets/ui_text.dart';

class SimpleChordFeedbackRow extends StatelessWidget {
  final List<int> playedMidiNumbers;
  final NoteState noteState;
  final NoteLanguage language;

  const SimpleChordFeedbackRow({
    super.key,
    required this.playedMidiNumbers,
    required this.noteState,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    if (playedMidiNumbers.isEmpty) return const SizedBox.shrink();

    final colors = AppColorTheme.of(context);
    final isCorrect = noteState == NoteState.correct;
    final chordColor = isCorrect ? AppColors.stateGreen : AppColors.stateRed;
    final stateLabel = isCorrect ? 'joué' : 'faux';
    final playedNames = playedMidiNumbers
        .map((midiNumber) => pitchClassLabel(midiNumber, language))
        .join(' ');

    return Row(
      children: [
        Icon(Icons.circle, size: 8, color: chordColor),
        const SizedBox(width: 6),
        UiText(
          playedNames,
          size: 14,
          weight: FontWeight.w600,
          color: chordColor,
        ),
        UiText(' · $stateLabel · suivant…', size: 14, color: colors.text2),
      ],
    );
  }
}
