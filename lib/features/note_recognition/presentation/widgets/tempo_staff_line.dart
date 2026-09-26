import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/utils/staff_paint_utils.dart';
import 'package:key_starter/features/note_recognition/domain/entities/tempo_timeline.dart';

/// Une ligne fixe de l'exercice Tempo : clé, une note par temps, et la barre
/// quand elle passe sur cette ligne. Une note qui vient d'être décidée gonfle
/// (juste) ou tremble (fausse, ratée).
class TempoStaffLine extends StatefulWidget {
  final List<int> noteSteps;
  final List<NoteState> noteStates;
  final ClefMode clef;

  /// Position de la barre dans la ligne (0 à 1), null si elle est ailleurs.
  final double? barFraction;
  final double height;

  const TempoStaffLine({
    super.key,
    required this.noteSteps,
    required this.noteStates,
    required this.clef,
    required this.barFraction,
    this.height = 100,
  });

  @override
  State<TempoStaffLine> createState() => _TempoStaffLineState();
}

class _TempoStaffLineState extends State<TempoStaffLine>
    with TickerProviderStateMixin {
  static const _feedbackDuration = Duration(milliseconds: 400);
  static const _swellScaleGain = 0.3;
  static const _shakeAmplitude = 12.0;
  static const _shakeOscillations = 3;

  late final List<AnimationController> _controllers = List.generate(
    TempoTimeline.notesPerLine,
    (_) => AnimationController(duration: _feedbackDuration, vsync: this),
  );

  @override
  void didUpdateWidget(TempoStaffLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (var index = 0; index < widget.noteStates.length; index++) {
      final wasIdle =
          index >= oldWidget.noteStates.length ||
          oldWidget.noteStates[index] == NoteState.idle;
      if (wasIdle && widget.noteStates[index] != NoteState.idle) {
        _controllers[index].forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lineColor = AppColorTheme.of(context).text;

    return AnimatedBuilder(
      animation: Listenable.merge(_controllers),
      builder: (context, _) {
        final noteCount = widget.noteSteps.length;
        return CustomPaint(
          size: Size(double.infinity, widget.height),
          painter: TempoStaffLinePainter(
            noteSteps: widget.noteSteps,
            noteColors: List.generate(
              noteCount,
              (index) => switch (widget.noteStates[index]) {
                NoteState.correct => AppColors.stateGreen,
                NoteState.wrong => AppColors.stateRed,
                NoteState.idle => lineColor,
              },
            ),
            noteScales: List.generate(noteCount, _scaleOf),
            noteShifts: List.generate(noteCount, _shiftOf),
            barFraction: widget.barFraction,
            clef: widget.clef,
            lineColor: lineColor,
          ),
        );
      },
    );
  }

  double _scaleOf(int index) {
    if (widget.noteStates[index] != NoteState.correct) return 1;
    return 1 + sin(_controllers[index].value * pi) * _swellScaleGain;
  }

  double _shiftOf(int index) {
    if (widget.noteStates[index] != NoteState.wrong) return 0;
    final progress = _controllers[index].value;
    if (progress == 1) return 0;
    return sin(progress * pi * 2 * _shakeOscillations) *
        _shakeAmplitude *
        (1 - progress);
  }
}

/// Dessine la portée, la clé, les notes (chacune avec sa couleur, son échelle
/// et son décalage horizontal) et la barre.
class TempoStaffLinePainter extends CustomPainter {
  static const double _clefPanelWidth = 70.0;

  final List<int> noteSteps;
  final List<Color> noteColors;
  final List<double> noteScales;
  final List<double> noteShifts;
  final double? barFraction;
  final ClefMode clef;
  final Color lineColor;

  const TempoStaffLinePainter({
    required this.noteSteps,
    required this.noteColors,
    required this.noteScales,
    required this.noteShifts,
    required this.barFraction,
    required this.clef,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final staffTop = staffTopFor(size);
    paintStaffLines(
      canvas,
      staffTop: staffTop,
      x1: 20,
      x2: size.width,
      lineColor: lineColor,
    );
    paintClefGlyph(
      canvas,
      clef: clef,
      x: 22,
      staffTop: staffTop,
      color: lineColor,
    );

    final notesWidth = size.width - _clefPanelWidth;
    final slotWidth = notesWidth / TempoTimeline.notesPerLine;
    for (var index = 0; index < noteSteps.length; index++) {
      final noteX = _clefPanelWidth + (index + 0.5) * slotWidth;
      final noteY = staffYFor(noteSteps[index], clef: clef, staffTop: staffTop);
      canvas.save();
      canvas.translate(noteX + noteShifts[index], noteY);
      canvas.scale(noteScales[index]);
      canvas.translate(-noteX, -noteY);
      paintNote(
        canvas,
        noteX: noteX,
        step: noteSteps[index],
        clef: clef,
        staffTop: staffTop,
        color: noteColors[index],
      );
      canvas.restore();
    }

    final fraction = barFraction;
    if (fraction != null) {
      final barX = _clefPanelWidth + fraction * notesWidth;
      canvas.drawLine(
        Offset(barX, staffTop - staffLineGap * 2),
        Offset(barX, staffTop + staffLineGap * 6),
        Paint()
          ..color = AppColors.notesFg
          ..strokeWidth = 3,
      );
    }
  }

  @override
  bool shouldRepaint(TempoStaffLinePainter old) =>
      old.barFraction != barFraction ||
      old.clef != clef ||
      old.lineColor != lineColor ||
      !listEquals(old.noteSteps, noteSteps) ||
      !listEquals(old.noteColors, noteColors) ||
      !listEquals(old.noteScales, noteScales) ||
      !listEquals(old.noteShifts, noteShifts);
}
