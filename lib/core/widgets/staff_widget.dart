import 'package:flutter/material.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';

enum NoteState { idle, correct, wrong }

// TODO: remplacer par le vrai CustomPainter de portée musicale.
class StaffWidget extends StatelessWidget {
  final int? diatonicStep;
  final ClefMode clef;
  final NoteState state;
  final bool showLetterBelow;
  final NoteLanguage language;

  const StaffWidget({
    super.key,
    this.diatonicStep,
    required this.clef,
    this.state = NoteState.idle,
    this.showLetterBelow = false,
    this.language = NoteLanguage.fr,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = switch (state) {
      NoteState.correct => AppColors.ok,
      NoteState.wrong => AppColors.err,
      NoteState.idle => AppColors.lineStrong,
    };

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.paper,
      ),
      child: Center(
        child: Text(
          'Staff — ${clef.name} · step ${diatonicStep ?? '–'}',
          style: AppTextStyles.mono(size: 12, color: AppColors.inkMute),
        ),
      ),
    );
  }
}
