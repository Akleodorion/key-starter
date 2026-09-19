import 'dart:math';

import 'package:flutter/material.dart';
import 'package:key_starter/core/enums/clef_mode.dart';

/// Écart vertical entre deux lignes de la portée, en pixels.
const double staffLineGap = 10.0;

/// Degré diatonique de la 1re ligne (ligne du bas) selon la clef.
const Map<ClefMode, int> staffBottomStep = {
  ClefMode.treble: 2,
  ClefMode.bass: -10,
};

/// Position Y du haut de la portée (1re ligne), centrée verticalement dans
/// [size] (les 5 lignes occupent 4 * [lineGap]).
double staffTopFor(Size size, {double lineGap = staffLineGap}) =>
    size.height / 2 - lineGap * 2;

/// Convertit un degré diatonique en coordonnée Y : chaque degré = [lineGap] / 2
/// pixels vers le haut, la ligne du bas de la portée servant de référence.
double staffYFor(
  int step, {
  required ClefMode clef,
  required double staffTop,
  double lineGap = staffLineGap,
}) {
  final bottomStep = staffBottomStep[clef]!;
  return staffTop + 4 * lineGap - (step - bottomStep) * lineGap / 2;
}

/// Dessine les 5 lignes de la portée entre [x1] et [x2].
void paintStaffLines(
  Canvas canvas, {
  required double staffTop,
  required double x1,
  required double x2,
  required Color lineColor,
  double lineGap = staffLineGap,
}) {
  final linePaint = Paint()
    ..color = lineColor.withValues(alpha: 0.85)
    ..strokeWidth = 1.1;

  for (var i = 0; i < 5; i++) {
    final y = staffTop + i * lineGap;
    canvas.drawLine(Offset(x1, y), Offset(x2, y), linePaint);
  }
}

/// Dessine le glyphe de clef (Sol ou Fa) via la police Bravura (SMuFL), avec
/// sa baseline alphabétique alignée sur la ligne d'ancrage de la clef.
void paintClefGlyph(
  Canvas canvas, {
  required ClefMode clef,
  required double x,
  required double staffTop,
  required Color color,
  double lineGap = staffLineGap,
}) {
  final glyph = clef == ClefMode.treble ? '𝄞' : '𝄢';
  final fontSize = clef == ClefMode.treble ? lineGap * 4 : lineGap * 3.5;
  final anchorY = clef == ClefMode.treble
      ? staffTop + lineGap * 3
      : staffTop + lineGap;

  final textPainter = TextPainter(
    text: TextSpan(
      text: glyph,
      style: TextStyle(fontSize: fontSize, color: color, fontFamily: 'Bravura'),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  final baseline = textPainter.computeDistanceToActualBaseline(
    TextBaseline.alphabetic,
  );
  textPainter.paint(canvas, Offset(x, anchorY - baseline));
}

/// Dessine une note (lignes supplémentaires, tête inclinée, hampe) à [noteX],
/// pour le degré diatonique [step] sur la clef [clef].
void paintNote(
  Canvas canvas, {
  required double noteX,
  required int step,
  required ClefMode clef,
  required double staffTop,
  required Color color,
  double lineGap = staffLineGap,
}) {
  final bottomStep = staffBottomStep[clef]!;
  final noteY = staffYFor(
    step,
    clef: clef,
    staffTop: staffTop,
    lineGap: lineGap,
  );
  final rx = lineGap * 0.75;
  final ry = lineGap * 0.55;

  // ── Lignes supplémentaires ──────────────────────────────────────────────
  final ledgerPaint = Paint()
    ..color = color
    ..strokeWidth = 1.2;

  if (step > bottomStep + 8) {
    for (var s = bottomStep + 10; s <= step; s += 2) {
      final ly = staffYFor(s, clef: clef, staffTop: staffTop, lineGap: lineGap);
      canvas.drawLine(
        Offset(noteX - 12, ly),
        Offset(noteX + 12, ly),
        ledgerPaint,
      );
    }
  } else if (step < bottomStep) {
    for (var s = bottomStep - 2; s >= step; s -= 2) {
      final ly = staffYFor(s, clef: clef, staffTop: staffTop, lineGap: lineGap);
      canvas.drawLine(
        Offset(noteX - 12, ly),
        Offset(noteX + 12, ly),
        ledgerPaint,
      );
    }
  }

  // ── Tête de note ──────────────────────────────────────────────────────
  canvas.save();
  canvas.translate(noteX, noteY);
  canvas.rotate(-22 * pi / 180);
  canvas.drawOval(
    Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2),
    Paint()..color = color,
  );
  canvas.restore();

  // ── Hampe ─────────────────────────────────────────────────────────────
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
