import 'package:flutter/material.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/utils/note_feedback_motion.dart';
import 'package:key_starter/core/utils/staff_paint_utils.dart';
import 'package:key_starter/core/utils/two_staff_judgement.dart';
import 'package:key_starter/core/widgets/note_feedback_motion.dart';
import 'package:key_starter/features/song_practice/domain/entities/song.dart';
import 'package:key_starter/features/song_practice/presentation/layout/score_line_note.dart';
import 'package:key_starter/features/song_practice/presentation/layout/song_line_layout.dart';

/// Une ligne de partition sur portée double : clés et accolade, barres de
/// mesure, numéro de la première mesure, chaque événement à sa place et
/// coloré selon son verdict, et le repère sur l'événement en cours. Celui-ci
/// gonfle (juste) ou tremble (faux) quand il vient d'être jugé.
class SongScoreLine extends StatelessWidget {
  final SongLine line;
  final Song song;
  final int measuresPerLine;
  final Map<int, TwoStaffVerdict> judgedVerdicts;

  /// Indice dans le morceau de l'événement à jouer ; null s'il n'est pas
  /// sur cette ligne.
  final int? currentEventIndex;
  final NoteState feedbackState;
  final bool trebleMuted;
  final bool bassMuted;
  final double height;

  const SongScoreLine({
    super.key,
    required this.line,
    required this.song,
    required this.measuresPerLine,
    required this.judgedVerdicts,
    required this.currentEventIndex,
    required this.feedbackState,
    required this.trebleMuted,
    required this.bassMuted,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final lineColor = AppColorTheme.of(context).text;
    final notes = [
      for (final placedEvent in line.events)
        _noteFor(placedEvent.eventIndex, placedEvent.position),
    ];
    final currentEvents = line.events.where(
      (placedEvent) => placedEvent.eventIndex == currentEventIndex,
    );
    final cursorPosition = currentEvents.isEmpty
        ? null
        : currentEvents.first.position;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: NoteFeedbackMotion(
        noteState: cursorPosition == null ? NoteState.idle : feedbackState,
        duration: noteAdvanceDelay,
        builder: (context, eventScale, eventShift) => CustomPaint(
          painter: SongScoreLinePainter(
            notes: notes,
            cursorPosition: cursorPosition,
            firstMeasureNumber: line.firstMeasureNumber,
            measureCount: line.measureCount,
            measuresPerLine: measuresPerLine,
            trebleMuted: trebleMuted,
            bassMuted: bassMuted,
            lineColor: lineColor,
            eventScale: eventScale,
            eventShift: eventShift,
          ),
        ),
      ),
    );
  }

  ScoreLineNote _noteFor(int eventIndex, double position) {
    final notes = song.events[eventIndex].notes;
    final verdict = judgedVerdicts[eventIndex];
    NoteState stateOf(StaffPartVerdict? staffVerdict) => staffVerdict == null
        ? NoteState.idle
        : staffVerdict.isCorrect
        ? NoteState.correct
        : NoteState.wrong;
    return ScoreLineNote(
      position: position,
      trebleSteps: notes.trebleSteps,
      bassSteps: notes.bassSteps,
      trebleState: trebleMuted || notes.trebleSteps.isEmpty
          ? NoteState.idle
          : stateOf(verdict?.treble),
      bassState: bassMuted || notes.bassSteps.isEmpty
          ? NoteState.idle
          : stateOf(verdict?.bass),
    );
  }
}

/// Dessine la ligne : deux portées reliées par l'accolade, leurs clés, les
/// barres de mesure, le numéro de mesure, les événements et le repère.
class SongScoreLinePainter extends CustomPainter {
  final List<ScoreLineNote> notes;
  final double? cursorPosition;
  final int firstMeasureNumber;
  final int measureCount;
  final int measuresPerLine;
  final bool trebleMuted;
  final bool bassMuted;
  final Color lineColor;
  final double eventScale;
  final double eventShift;

  const SongScoreLinePainter({
    required this.notes,
    required this.cursorPosition,
    required this.firstMeasureNumber,
    required this.measureCount,
    required this.measuresPerLine,
    required this.trebleMuted,
    required this.bassMuted,
    required this.lineColor,
    this.eventScale = 1,
    this.eventShift = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Deux portées (4 écarts chacune) séparées de 4 écarts, plus la place des
    // lignes supplémentaires au-dessus et en dessous : ≈ 18 écarts au total.
    final lineGap = (size.height / 18).clamp(5.0, maxStaffLineGap);
    final trebleTop = size.height / 2 - lineGap * 6;
    final bassTop = trebleTop + lineGap * 8;
    final systemBottom = bassTop + lineGap * 4;
    final staffLeft = lineGap * 2;
    final notesLeft = staffLeft + lineGap * 5;
    final measureWidth = (size.width - lineGap - notesLeft) / measuresPerLine;
    final staffRight = notesLeft + measureWidth * measureCount;

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
    paintBrace(
      canvas,
      x: staffLeft,
      top: trebleTop,
      bottom: systemBottom,
      color: lineColor,
      lineGap: lineGap,
    );
    _paintBarLines(
      canvas,
      notesLeft: notesLeft,
      measureWidth: measureWidth,
      top: trebleTop,
      bottom: systemBottom,
      lineGap: lineGap,
    );
    _paintMeasureNumber(canvas, x: staffLeft, y: trebleTop, lineGap: lineGap);

    double noteX(double position) {
      final measureSlots = position * measuresPerLine;
      final slot = measureSlots.floor();
      final fractionInMeasure = measureSlots - slot;
      final leftPadding = lineGap * 1.8;
      final rightPadding = lineGap * 1.2;
      return notesLeft +
          slot * measureWidth +
          leftPadding +
          fractionInMeasure * (measureWidth - leftPadding - rightPadding);
    }

    final cursor = cursorPosition;
    if (cursor != null) {
      canvas.drawLine(
        Offset(noteX(cursor), trebleTop - lineGap * 2),
        Offset(noteX(cursor), systemBottom + lineGap * 2),
        Paint()
          ..color = AppColors.songsFg.withValues(alpha: 0.6)
          ..strokeWidth = lineGap * 0.3,
      );
    }

    for (final note in notes) {
      final x = noteX(note.position);
      final isCurrent = note.position == cursor;
      canvas.save();
      if (isCurrent) {
        final centerY = (trebleTop + systemBottom) / 2;
        canvas.translate(x + eventShift, centerY);
        canvas.scale(eventScale);
        canvas.translate(-x, -centerY);
      }
      paintChord(
        canvas,
        noteX: x,
        steps: note.trebleSteps,
        clef: ClefMode.treble,
        staffTop: trebleTop,
        color: _colorFor(note.trebleState, isMuted: trebleMuted),
        lineGap: lineGap,
      );
      paintChord(
        canvas,
        noteX: x,
        steps: note.bassSteps,
        clef: ClefMode.bass,
        staffTop: bassTop,
        color: _colorFor(note.bassState, isMuted: bassMuted),
        lineGap: lineGap,
      );
      canvas.restore();
    }
  }

  Color _colorFor(NoteState state, {required bool isMuted}) => isMuted
      ? lineColor.withValues(alpha: 0.3)
      : switch (state) {
          NoteState.correct => AppColors.stateGreen,
          NoteState.wrong => AppColors.stateRed,
          NoteState.idle => lineColor,
        };

  /// Une barre à la fin de chaque mesure, à travers les deux portées.
  void _paintBarLines(
    Canvas canvas, {
    required double notesLeft,
    required double measureWidth,
    required double top,
    required double bottom,
    required double lineGap,
  }) {
    final barPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.85)
      ..strokeWidth = lineGap * 0.11;
    for (var measure = 1; measure <= measureCount; measure++) {
      final x = notesLeft + measure * measureWidth;
      canvas.drawLine(Offset(x, top), Offset(x, bottom), barPaint);
    }
  }

  void _paintMeasureNumber(
    Canvas canvas, {
    required double x,
    required double y,
    required double lineGap,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$firstMeasureNumber',
        style: TextStyle(fontSize: lineGap * 1.3, color: lineColor),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(x, y - lineGap * 2.6 - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(SongScoreLinePainter old) =>
      old.notes != notes ||
      old.cursorPosition != cursorPosition ||
      old.firstMeasureNumber != firstMeasureNumber ||
      old.measureCount != measureCount ||
      old.trebleMuted != trebleMuted ||
      old.bassMuted != bassMuted ||
      old.lineColor != lineColor ||
      old.eventScale != eventScale ||
      old.eventShift != eventShift;
}
