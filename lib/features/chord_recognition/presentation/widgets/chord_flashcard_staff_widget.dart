import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/utils/note_feedback_motion.dart';
import 'package:key_starter/core/utils/staff_paint_utils.dart';
import 'package:key_starter/core/widgets/note_feedback_motion.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/chord_flashcard_exercise_notifier.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/chord_flashcard_exercise_state.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_exercise_settings_state.dart';

/// Portée affichant l'accord courant de [chordFlashcardExerciseProvider].
/// L'accord gonfle (juste) ou tremble (faux) quand il est jugé.
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
    final noteState = running?.noteState ?? NoteState.idle;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: NoteFeedbackMotion(
        noteState: noteState,
        duration: noteAdvanceDelay,
        builder: (context, chordScale, chordShift) => CustomPaint(
          painter: ChordFlashcardStaffPainter(
            clef: settings.clef,
            steps: running?.currentChord ?? const [],
            state: noteState,
            lineColor: lineColor,
            chordScale: chordScale,
            chordShift: chordShift,
          ),
        ),
      ),
    );
  }
}

/// Dessine la portée, la clef et l'accord, mis à l'échelle et décalé
/// horizontalement autour de son centre.
class ChordFlashcardStaffPainter extends CustomPainter {
  final ClefMode clef;
  final List<int> steps;
  final NoteState state;
  final Color lineColor;
  final double chordScale;
  final double chordShift;

  const ChordFlashcardStaffPainter({
    required this.clef,
    required this.steps,
    required this.state,
    required this.lineColor,
    this.chordScale = 1,
    this.chordShift = 0,
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
    final chordX = size.width / 2 + 30;
    final lowestY = staffYFor(
      steps.reduce(min),
      clef: clef,
      staffTop: staffTop,
    );
    final highestY = staffYFor(
      steps.reduce(max),
      clef: clef,
      staffTop: staffTop,
    );
    final chordCenterY = (lowestY + highestY) / 2;
    canvas.save();
    canvas.translate(chordX + chordShift, chordCenterY);
    canvas.scale(chordScale);
    canvas.translate(-chordX, -chordCenterY);
    paintChord(
      canvas,
      noteX: chordX,
      steps: steps,
      clef: clef,
      staffTop: staffTop,
      color: chordColor,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(ChordFlashcardStaffPainter old) =>
      old.chordScale != chordScale ||
      old.chordShift != chordShift ||
      old.clef != clef ||
      old.steps != steps ||
      old.state != state ||
      old.lineColor != lineColor;
}
