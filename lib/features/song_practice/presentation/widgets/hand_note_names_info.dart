import 'package:flutter/material.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/core/utils/two_staff_judgement.dart';
import 'package:key_starter/core/widgets/ui_text.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/hand_played_keys_label.dart';

/// Notes attendues d'une main et, une fois jugée, les touches qui lui ont été
/// attribuées.
class HandNoteNamesInfo extends StatelessWidget {
  final String handLabel;
  final List<int> expectedSteps;
  final StaffPartVerdict? verdict;
  final NoteLanguage language;

  const HandNoteNamesInfo({
    super.key,
    required this.handLabel,
    required this.expectedSteps,
    required this.verdict,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);
    final expectedNames = expectedSteps
        .map((step) => noteLabel(step, language))
        .join(' · ');
    final currentVerdict = verdict;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UiText('$handLabel : $expectedNames', size: 14, color: colors.text),
        if (currentVerdict != null) ...[
          const SizedBox(height: 4),
          HandPlayedKeysLabel(verdict: currentVerdict, language: language),
        ],
      ],
    );
  }
}
