import 'package:flutter/material.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/core/utils/two_staff_judgement.dart';
import 'package:key_starter/core/widgets/ui_text.dart';

/// Touches attribuées à une main, du grave à l'aigu, en vert si la portée
/// est juste, en rouge sinon.
class HandPlayedKeysLabel extends StatelessWidget {
  final StaffPartVerdict verdict;
  final NoteLanguage language;

  const HandPlayedKeysLabel({
    super.key,
    required this.verdict,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final sortedMidiNumbers = verdict.playedMidiNumbers.toList()..sort();
    final playedNames = sortedMidiNumbers
        .map((midiNumber) {
          final octave = midiNumber ~/ 12 - 1;
          return '${pitchClassLabel(midiNumber, language)} $octave';
        })
        .join(' · ');

    return UiText(
      'Joué : $playedNames',
      size: 13,
      color: verdict.isCorrect ? AppColors.stateGreen : AppColors.stateRed,
    );
  }
}
