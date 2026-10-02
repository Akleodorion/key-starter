import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/models/two_staff_event.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/utils/note_feedback_motion.dart';
import 'package:key_starter/core/utils/staff_paint_utils.dart';
import 'package:key_starter/core/widgets/note_feedback_motion.dart';

/// Widget abstrait de portée double (clé de sol au-dessus, clé de fa
/// en dessous, reliées par une accolade) affichant un [TwoStaffEvent].
///
/// Chaque groupe est écrit sur sa propre portée, les deux à la même abscisse
/// puisqu'ils se jouent ensemble ; chaque portée prend la couleur de son
/// propre état. L'événement gonfle si tout est juste, tremble sinon.
///
/// Les sous-classes fournissent l'événement et l'état de chaque portée.
///
/// ```dart
/// class TwoStaffFlashcardStaffWidget extends GrandStaffWidget {
///   const TwoStaffFlashcardStaffWidget({super.key});
///
///   @override
///   TwoStaffEvent? event(WidgetRef ref) => _running(ref)?.event;
///
///   @override
///   NoteState noteState(WidgetRef ref, ClefMode clef) { ... }
/// }
/// ```
///
/// Voir aussi : [TwoStaffFlashcardStaffWidget]
abstract class GrandStaffWidget extends ConsumerWidget {
  /// Hauteur du widget ; null = toute la hauteur disponible.
  final double? height;

  const GrandStaffWidget({super.key, this.height});

  /// Événement à afficher ; null = portées vides.
  TwoStaffEvent? event(WidgetRef ref);

  /// État visuel du groupe de notes de la portée [clef].
  NoteState noteState(WidgetRef ref, ClefMode clef);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lineColor = AppColorTheme.of(context).text;
    final currentEvent = event(ref);
    final trebleState = noteState(ref, ClefMode.treble);
    final bassState = noteState(ref, ClefMode.bass);
    final motionState =
        trebleState == NoteState.wrong || bassState == NoteState.wrong
        ? NoteState.wrong
        : trebleState == NoteState.correct && bassState == NoteState.correct
        ? NoteState.correct
        : NoteState.idle;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: NoteFeedbackMotion(
        noteState: motionState,
        duration: noteAdvanceDelay,
        builder: (context, eventScale, eventShift) => CustomPaint(
          painter: GrandStaffPainter(
            trebleSteps: currentEvent?.trebleSteps ?? const [],
            bassSteps: currentEvent?.bassSteps ?? const [],
            trebleState: trebleState,
            bassState: bassState,
            lineColor: lineColor,
            eventScale: eventScale,
            eventShift: eventShift,
          ),
        ),
      ),
    );
  }
}

/// Dessine les deux portées, leurs clefs, l'accolade et l'événement, mis à
/// l'échelle et décalé horizontalement autour de son centre.
class GrandStaffPainter extends CustomPainter {
  final List<int> trebleSteps;
  final List<int> bassSteps;
  final NoteState trebleState;
  final NoteState bassState;
  final Color lineColor;
  final double eventScale;
  final double eventShift;

  const GrandStaffPainter({
    required this.trebleSteps,
    required this.bassSteps,
    required this.trebleState,
    required this.bassState,
    required this.lineColor,
    this.eventScale = 1,
    this.eventShift = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Deux portées (4 écarts chacune) séparées de 4 écarts, plus la place des
    // lignes supplémentaires au-dessus et en dessous : ≈ 18 écarts au total.
    final lineGap = (size.height / 18).clamp(6.0, maxStaffLineGap);
    final trebleTop = size.height / 2 - lineGap * 6;
    final bassTop = trebleTop + lineGap * 8;
    final staffLeft = lineGap * 2;
    final staffRight = size.width - lineGap * 2;

    for (final (clef, staffTop) in [
      (ClefMode.treble, trebleTop),
      (ClefMode.bass, bassTop),
    ]) {
      paintStaffLines(
        canvas,
        staffTop: staffTop,
        x1: staffLeft,
        x2: staffRight,
        lineColor: lineColor,
        lineGap: lineGap,
      );
      paintClefGlyph(
        canvas,
        clef: clef,
        x: staffLeft + lineGap * 0.2,
        staffTop: staffTop,
        color: lineColor,
        lineGap: lineGap,
      );
    }
    _paintBrace(
      canvas,
      x: staffLeft,
      top: trebleTop,
      bottom: bassTop + lineGap * 4,
      lineGap: lineGap,
    );

    final noteX = size.width / 2 + lineGap * 3;
    final noteYs = [
      for (final step in trebleSteps)
        staffYFor(
          step,
          clef: ClefMode.treble,
          staffTop: trebleTop,
          lineGap: lineGap,
        ),
      for (final step in bassSteps)
        staffYFor(
          step,
          clef: ClefMode.bass,
          staffTop: bassTop,
          lineGap: lineGap,
        ),
    ];
    if (noteYs.isEmpty) return;
    final eventCenterY = (noteYs.reduce(min) + noteYs.reduce(max)) / 2;

    canvas.save();
    canvas.translate(noteX + eventShift, eventCenterY);
    canvas.scale(eventScale);
    canvas.translate(-noteX, -eventCenterY);
    paintChord(
      canvas,
      noteX: noteX,
      steps: trebleSteps,
      clef: ClefMode.treble,
      staffTop: trebleTop,
      color: _colorFor(trebleState),
      lineGap: lineGap,
    );
    paintChord(
      canvas,
      noteX: noteX,
      steps: bassSteps,
      clef: ClefMode.bass,
      staffTop: bassTop,
      color: _colorFor(bassState),
      lineGap: lineGap,
    );
    canvas.restore();
  }

  Color _colorFor(NoteState state) => switch (state) {
    NoteState.correct => AppColors.stateGreen,
    NoteState.wrong => AppColors.stateRed,
    NoteState.idle => lineColor,
  };

  /// Trait vertical qui relie les deux portées, et l'accolade à sa gauche.
  void _paintBrace(
    Canvas canvas, {
    required double x,
    required double top,
    required double bottom,
    required double lineGap,
  }) {
    final systemLinePaint = Paint()
      ..color = lineColor.withValues(alpha: 0.85)
      ..strokeWidth = lineGap * 0.11;
    canvas.drawLine(Offset(x, top), Offset(x, bottom), systemLinePaint);

    final braceX = x - lineGap * 0.5;
    final middle = (top + bottom) / 2;
    final span = bottom - top;
    final bracePath = Path()
      ..moveTo(braceX, top)
      ..cubicTo(
        braceX - lineGap * 0.9,
        top + span * 0.1,
        braceX + lineGap * 0.1,
        middle - span * 0.15,
        braceX - lineGap * 0.8,
        middle,
      )
      ..cubicTo(
        braceX + lineGap * 0.1,
        middle + span * 0.15,
        braceX - lineGap * 0.9,
        bottom - span * 0.1,
        braceX,
        bottom,
      );
    canvas.drawPath(
      bracePath,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineGap * 0.25,
    );
  }

  @override
  bool shouldRepaint(GrandStaffPainter old) =>
      old.eventScale != eventScale ||
      old.eventShift != eventShift ||
      old.trebleSteps != trebleSteps ||
      old.bassSteps != bassSteps ||
      old.trebleState != trebleState ||
      old.bassState != bassState ||
      old.lineColor != lineColor;
}
