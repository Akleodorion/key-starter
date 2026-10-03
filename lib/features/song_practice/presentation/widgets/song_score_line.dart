import 'dart:math';

import 'package:flutter/foundation.dart';
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
import 'package:key_starter/features/song_practice/domain/entities/song_section.dart';
import 'package:key_starter/features/song_practice/presentation/layout/score_line_note.dart';
import 'package:key_starter/features/song_practice/presentation/layout/score_line_rest.dart';
import 'package:key_starter/features/song_practice/presentation/layout/song_line_layout.dart';
import 'package:key_starter/features/song_practice/presentation/painting/song_figure_painting.dart';

/// Une ligne de partition sur portée double : clés et accolade, barres de
/// mesure, numéro de la première mesure, fond teinté derrière les mesures de
/// la section travaillée, chaque événement à sa place et coloré selon son
/// verdict, et le repère sur l'événement en cours (ou la barre du tempo).
/// L'événement en cours gonfle (juste) ou tremble (faux) quand il vient
/// d'être jugé.
class SongScoreLine extends StatelessWidget {
  final SongLine line;
  final Song song;
  final int measuresPerLine;
  final Map<int, TwoStaffVerdict> judgedVerdicts;

  /// Indice dans le morceau de l'événement à jouer ; null s'il n'est pas
  /// sur cette ligne.
  final int? currentEventIndex;

  /// Position de la barre du tempo dans cette ligne, de 0 à 1 ; null si elle
  /// n'est pas sur cette ligne.
  final double? barPosition;
  final NoteState feedbackState;
  final bool trebleMuted;
  final bool bassMuted;
  final SongSection section;
  final double height;

  const SongScoreLine({
    super.key,
    required this.line,
    required this.song,
    required this.measuresPerLine,
    required this.judgedVerdicts,
    required this.currentEventIndex,
    this.barPosition,
    required this.feedbackState,
    required this.trebleMuted,
    required this.bassMuted,
    required this.section,
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
            rests: [
              for (final placedRest in line.rests)
                ScoreLineRest(
                  position: placedRest.position,
                  isBass: song.rests[placedRest.restIndex].isBass,
                  value: song.rests[placedRest.restIndex].value,
                ),
            ],
            sectionSlots: [
              for (var slot = 0; slot < line.measureCount; slot++)
                if (section.contains(line.measures[slot].number)) slot,
            ],
            cursorPosition: cursorPosition ?? barPosition,
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
    final event = song.events[eventIndex];
    return ScoreLineNote(
      position: position,
      trebleSteps: notes.trebleSteps,
      bassSteps: notes.bassSteps,
      trebleNotation: event.trebleNotation,
      bassNotation: event.bassNotation,
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
/// barres de mesure, le numéro de mesure, les figures de notes et de
/// silences, et le repère.
class SongScoreLinePainter extends CustomPainter {
  final List<ScoreLineNote> notes;
  final List<ScoreLineRest> rests;

  /// Places, dans la ligne, des mesures de la section travaillée.
  final List<int> sectionSlots;
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
    this.rests = const [],
    required this.sectionSlots,
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

    final sectionPaint = Paint()
      ..color = AppColors.songsTint.withValues(alpha: 0.7);
    for (final slot in sectionSlots) {
      canvas.drawRect(
        Rect.fromLTRB(
          notesLeft + slot * measureWidth,
          trebleTop - lineGap,
          notesLeft + (slot + 1) * measureWidth,
          systemBottom + lineGap,
        ),
        sectionPaint,
      );
    }

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
      // La fin de la dernière mesure reste dans la ligne.
      final slot = min(measureSlots.floor(), measuresPerLine - 1);
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

    for (final (isBass, staffTop, isMuted) in [
      (false, trebleTop, trebleMuted),
      (true, bassTop, bassMuted),
    ]) {
      paintStaffFigures(
        canvas,
        notes: notes,
        rests: rests,
        isBass: isBass,
        staffTop: staffTop,
        lineGap: lineGap,
        noteX: noteX,
        colorFor: (state) => _colorFor(state, isMuted: isMuted),
        restColor: _colorFor(NoteState.idle, isMuted: isMuted),
        currentPosition: cursor,
        eventScale: eventScale,
        eventShift: eventShift,
        centerY: (trebleTop + systemBottom) / 2,
      );
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
      !listEquals(old.rests, rests) ||
      !listEquals(old.sectionSlots, sectionSlots) ||
      old.cursorPosition != cursorPosition ||
      old.firstMeasureNumber != firstMeasureNumber ||
      old.measureCount != measureCount ||
      old.trebleMuted != trebleMuted ||
      old.bassMuted != bassMuted ||
      old.lineColor != lineColor ||
      old.eventScale != eventScale ||
      old.eventShift != eventShift;
}
