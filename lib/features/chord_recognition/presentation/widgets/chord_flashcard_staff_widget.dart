import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/utils/staff_paint_utils.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/chord_flashcard_exercise_notifier.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/chord_flashcard_exercise_state.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_exercise_settings_state.dart';

/// Portée affichant l'accord courant de [chordFlashcardExerciseProvider].
///
/// Ne sous-classe pas [StaffWidget] (dont le contrat est mono-note) —
/// spécifique à cette feature, comme `DefilementStaffWidget`.
class ChordFlashcardStaffWidget extends ConsumerWidget {
  final NoteExerciseSettings settings;
  final double height;

  const ChordFlashcardStaffWidget({
    super.key,
    required this.settings,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lineColor = AppColorTheme.of(context).text;
    final exerciseState = ref.watch(chordFlashcardExerciseProvider(settings));
    final running = exerciseState is ChordFlashcardExerciseRunning
        ? exerciseState
        : null;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _ChordFlashcardStaffPainter(
          clef: settings.clef,
          steps: running?.currentChord ?? const [],
          state: running?.noteState ?? NoteState.idle,
          lineColor: lineColor,
        ),
      ),
    );
  }
}

class _ChordFlashcardStaffPainter extends CustomPainter {
  final ClefMode clef;
  final List<int> steps;
  final NoteState state;
  final Color lineColor;

  const _ChordFlashcardStaffPainter({
    required this.clef,
    required this.steps,
    required this.state,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final staffTop = staffTopFor(size);

    paintStaffLines(
      canvas,
      staffTop: staffTop,
      x1: 20,
      x2: size.width - 20,
      lineColor: lineColor,
    );
    paintClefGlyph(
      canvas,
      clef: clef,
      x: 22,
      staffTop: staffTop,
      color: lineColor,
    );

    if (steps.isEmpty) return;

    final chordColor = switch (state) {
      NoteState.correct => AppColors.stateGreen,
      NoteState.wrong => AppColors.stateRed,
      NoteState.idle => lineColor,
    };
    paintChord(
      canvas,
      noteX: size.width / 2 + 30,
      steps: steps,
      clef: clef,
      staffTop: staffTop,
      color: chordColor,
    );
  }

  @override
  bool shouldRepaint(_ChordFlashcardStaffPainter old) =>
      old.clef != clef ||
      old.steps != steps ||
      old.state != state ||
      old.lineColor != lineColor;
}
