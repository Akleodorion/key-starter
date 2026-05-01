import 'dart:math';

import 'package:flutter/material.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/theme/app_colors.dart';

class StaffRangeWidget extends StatelessWidget {
  final ClefMode clef;
  final int minDiatonicStep;
  final int maxDiatonicStep;
  final double height;

  const StaffRangeWidget({
    super.key,
    required this.clef,
    required this.minDiatonicStep,
    required this.maxDiatonicStep,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _StaffRangePainter(
          clef: clef,
          minDiatonicStep: minDiatonicStep,
          maxDiatonicStep: maxDiatonicStep,
        ),
      ),
    );
  }
}

class _StaffRangePainter extends CustomPainter {
  final ClefMode clef;
  final int minDiatonicStep;
  final int maxDiatonicStep;

  static const _bottomStep = {ClefMode.treble: 2, ClefMode.bass: -10};

  const _StaffRangePainter({
    required this.clef,
    required this.minDiatonicStep,
    required this.maxDiatonicStep,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const lineGap = 10.0;
    final staffTop = size.height / 2 - lineGap * 2;
    final bottomStep = _bottomStep[clef]!;
    final noteX = size.width / 2 + 30;
    final rx = lineGap * 0.75;
    final ry = lineGap * 0.55;

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

    // ── Note min (accent) — note max (accentDeep) ─────────────────────────────
    const noteSpacing = 40.0;
    _paintNote(canvas, noteX - noteSpacing, yFor(minDiatonicStep), rx, ry,
        lineGap, AppColors.accent, minDiatonicStep, bottomStep, yFor);
    _paintNote(canvas, noteX + noteSpacing, yFor(maxDiatonicStep), rx, ry,
        lineGap, AppColors.accentDeep, maxDiatonicStep, bottomStep, yFor);
  }

  void _paintNote(
    Canvas canvas,
    double noteX,
    double noteY,
    double rx,
    double ry,
    double lineGap,
    Color color,
    int step,
    int bottomStep,
    double Function(int) yFor,
  ) {
    final ledgerPaint = Paint()
      ..color = color
      ..strokeWidth = 1.2;

    if (step > bottomStep + 8) {
      for (var s = bottomStep + 10; s <= step; s += 2) {
        canvas.drawLine(Offset(noteX - 12, yFor(s)), Offset(noteX + 12, yFor(s)),
            ledgerPaint);
      }
    } else if (step < bottomStep) {
      for (var s = bottomStep - 2; s >= step; s -= 2) {
        canvas.drawLine(Offset(noteX - 12, yFor(s)), Offset(noteX + 12, yFor(s)),
            ledgerPaint);
      }
    }

    canvas.save();
    canvas.translate(noteX, noteY);
    canvas.rotate(-22 * pi / 180);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2),
      Paint()..color = color,
    );
    canvas.restore();

    final stemPaint = Paint()
      ..color = color
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
  bool shouldRepaint(_StaffRangePainter old) =>
      old.clef != clef ||
      old.minDiatonicStep != minDiatonicStep ||
      old.maxDiatonicStep != maxDiatonicStep;
}
