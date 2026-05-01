import 'dart:math';

import 'package:flutter/material.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/theme/app_colors.dart';

enum NoteState { idle, correct, wrong }

class StaffWidget extends StatelessWidget {
  final int? diatonicStep;
  final ClefMode clef;
  final NoteState state;
  final bool showLetterBelow;
  final NoteLanguage language;
  final double height;

  const StaffWidget({
    super.key,
    this.diatonicStep,
    required this.clef,
    this.state = NoteState.idle,
    this.showLetterBelow = false,
    this.language = NoteLanguage.fr,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _StaffPainter(
          clef: clef,
          diatonicStep: diatonicStep,
          state: state,
        ),
      ),
    );
  }
}

class _StaffPainter extends CustomPainter {
  final ClefMode clef;
  final int? diatonicStep;
  final NoteState state;

  static const _bottomStep = {ClefMode.treble: 2, ClefMode.bass: -10};

  const _StaffPainter({
    required this.clef,
    required this.diatonicStep,
    required this.state,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const lineGap = 10.0;
    final staffTop = size.height / 2 - lineGap * 2;
    final bottomStep = _bottomStep[clef]!;

    double yFor(int s) =>
        staffTop + 4 * lineGap - (s - bottomStep) * lineGap / 2;

    // ── 5 lignes ──────────────────────────────────────────────────────────────
    final linePaint = Paint()
      ..color = AppColors.ink.withValues(alpha: 0.85)
      ..strokeWidth = 1.1;

    for (var i = 0; i < 5; i++) {
      final y = staffTop + i * lineGap;
      canvas.drawLine(Offset(20, y), Offset(size.width - 20, y), linePaint);
    }

    // ── Glyphe de clef ────────────────────────────────────────────────────────
    final glyph = clef == ClefMode.treble ? '𝄞' : '𝄢';
    final fontSize = clef == ClefMode.treble ? lineGap * 6 : lineGap * 4;
    final glyphY = clef == ClefMode.treble
        ? staffTop + lineGap * 2 + fontSize * 0.40
        : staffTop + lineGap + fontSize * 0.78;

    final tp = TextPainter(
      text: TextSpan(
        text: glyph,
        style: TextStyle(
          fontSize: fontSize,
          color: AppColors.ink,
          fontFamily: 'serif',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, Offset(22, glyphY - tp.height));

    // ── Note (si présente) ────────────────────────────────────────────────────
    final step = diatonicStep;
    if (step == null) return;

    final noteColor = switch (state) {
      NoteState.correct => AppColors.ok,
      NoteState.wrong => AppColors.err,
      NoteState.idle => AppColors.ink,
    };
    final noteX = size.width / 2 + 30;
    final noteY = yFor(step);
    final rx = lineGap * 0.75;
    final ry = lineGap * 0.55;

    final ledgerPaint = Paint()
      ..color = noteColor
      ..strokeWidth = 1.2;

    if (step > bottomStep + 8) {
      for (var s = bottomStep + 10; s <= step; s += 2) {
        final ly = yFor(s);
        canvas.drawLine(
            Offset(noteX - 12, ly), Offset(noteX + 12, ly), ledgerPaint);
      }
    } else if (step < bottomStep) {
      for (var s = bottomStep - 2; s >= step; s -= 2) {
        final ly = yFor(s);
        canvas.drawLine(
            Offset(noteX - 12, ly), Offset(noteX + 12, ly), ledgerPaint);
      }
    }

    canvas.save();
    canvas.translate(noteX, noteY);
    canvas.rotate(-22 * pi / 180);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2),
      Paint()..color = noteColor,
    );
    canvas.restore();

    final stemPaint = Paint()
      ..color = noteColor
      ..strokeWidth = 1.6;

    if (step >= bottomStep + 4) {
      canvas.drawLine(
        Offset(noteX - rx, noteY + 1),
        Offset(noteX - rx, noteY + lineGap * 3),
        stemPaint,
      );
    } else {
      canvas.drawLine(
        Offset(noteX + rx, noteY - 1),
        Offset(noteX + rx, noteY - lineGap * 3),
        stemPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_StaffPainter old) =>
      old.clef != clef ||
      old.diatonicStep != diatonicStep ||
      old.state != state;
}
