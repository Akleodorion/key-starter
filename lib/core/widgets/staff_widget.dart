import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/theme/app_colors.dart';

/// Widget abstrait de portée musicale avec note positionnée.
///
/// Dessine une portée à 5 lignes, le glyphe de clef (Sol ou Fa) et,
/// si [diatonicStep] est non-null, la note correspondante colorée selon
/// [noteState]. Les lignes supplémentaires sont ajoutées automatiquement.
///
/// Les sous-classes fournissent la clef, le degré diatonique et l'état
/// de la note en implémentant [clef], [diatonicStep] et [noteState].
///
/// ```dart
/// class LessonStaffWidget extends StaffWidget {
///   final Session session;
///   const LessonStaffWidget({super.key, required this.session, super.height});
///
///   @override ClefMode clef(WidgetRef ref) => session.clef;
///   @override int? diatonicStep(WidgetRef ref) => _inProgress(ref)?.currentStep;
///   @override NoteState noteState(WidgetRef ref) { ... }
/// }
/// ```
///
/// Voir aussi : [LessonStaffWidget], [SessionStaffWidget]
abstract class StaffWidget extends ConsumerWidget {
  final double height;
  final double? staffwidth;

  const StaffWidget({super.key, this.height = 100, this.staffwidth});

  /// Clef à afficher (Sol ou Fa).
  ClefMode clef(WidgetRef ref);

  /// Degré diatonique de la note à afficher ; null = aucune note.
  int? diatonicStep(WidgetRef ref);

  /// État visuel de la note (neutre, correct, erroné).
  NoteState noteState(WidgetRef ref);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: height,
      width: staffwidth ?? double.infinity,
      child: CustomPaint(
        painter: _StaffPainter(
          clef: clef(ref),
          diatonicStep: diatonicStep(ref),
          state: noteState(ref),
        ),
      ),
    );
  }
}

/// Dessine la portée, le glyphe de clef et la note sur un [Canvas].
///
/// Système de coordonnées
/// ─────────────────────
/// [_bottomStep] définit le degré diatonique de la 1re ligne de la portée
/// (ligne du bas) selon la clef :
///   • Sol (treble) → Do 4  (step 2)
///   • Fa  (bass)   → Mi 2  (step -10)
///
/// [yFor] convertit un degré diatonique en coordonnée Y :
///   • chaque demi-ton diatonique = lineGap / 2 pixels vers le haut
///   • la 1re ligne (bottomStep) correspond à staffTop + 4 * lineGap
///     (bas de la portée), et les degrés croissants remontent.
class _StaffPainter extends CustomPainter {
  final ClefMode clef;
  final int? diatonicStep;
  final NoteState state;

  // Degré diatonique de la 1re ligne (ligne du bas) selon la clef.
  static const _bottomStep = {ClefMode.treble: 2, ClefMode.bass: -10};

  const _StaffPainter({
    required this.clef,
    required this.diatonicStep,
    required this.state,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const lineGap = 10.0;
    // Centre la portée verticalement : les 5 lignes occupent 4 * lineGap.
    final staffTop = size.height / 2 - lineGap * 2;
    final bottomStep = _bottomStep[clef]!;

    // Convertit un degré diatonique en Y : chaque degré = lineGap / 2 px vers le haut.
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
    // Police Bravura (SMuFL) : la baseline alphabétique du glyphe coïncide avec
    // la ligne d'ancrage de la clef.
    // Clef de Sol → ligne Sol = 2e ligne depuis le bas = staffTop + 3 * lineGap.
    // Clef de Fa  → ligne Fa  = 4e ligne depuis le bas = staffTop + lineGap.
    // On soustrait la baseline mesurée pour aligner le glyphe sur anchorY.
    final glyph = clef == ClefMode.treble ? '𝄞' : '𝄢';
    final fontSize = clef == ClefMode.treble ? lineGap * 4 : lineGap * 3.5;
    final anchorY = clef == ClefMode.treble
        ? staffTop + lineGap * 3
        : staffTop + lineGap;

    final tp = TextPainter(
      text: TextSpan(
        text: glyph,
        style: TextStyle(
          fontSize: fontSize,
          color: AppColors.ink,
          fontFamily: 'Bravura',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final baseline = tp.computeDistanceToActualBaseline(TextBaseline.alphabetic);
    tp.paint(canvas, Offset(22, anchorY - baseline));

    // ── Note (si présente) ────────────────────────────────────────────────────
    final step = diatonicStep;
    if (step == null) return;

    final noteColor = switch (state) {
      NoteState.correct => AppColors.ok,
      NoteState.wrong => AppColors.err,
      NoteState.idle => AppColors.ink,
    };
    // La note est centrée horizontalement, décalée à droite de la clef.
    final noteX = size.width / 2 + 30;
    final noteY = yFor(step);
    // Demi-axes de l'ovale : légèrement plus large que haut.
    final rx = lineGap * 0.75;
    final ry = lineGap * 0.55;

    // ── Lignes supplémentaires ────────────────────────────────────────────────
    // Au-dessus : la portée couvre bottomStep à bottomStep+8 (5 lignes = 9 degrés).
    // Chaque ligne supplémentaire s'ajoute tous les 2 degrés (une ligne = 2 degrés).
    final ledgerPaint = Paint()
      ..color = noteColor
      ..strokeWidth = 1.2;

    if (step > bottomStep + 8) {
      // Lignes au-dessus de la portée : de la 1re ligne sup jusqu'à la note.
      for (var s = bottomStep + 10; s <= step; s += 2) {
        final ly = yFor(s);
        canvas.drawLine(
          Offset(noteX - 12, ly),
          Offset(noteX + 12, ly),
          ledgerPaint,
        );
      }
    } else if (step < bottomStep) {
      // Lignes en dessous de la portée : de la 1re ligne inf jusqu'à la note.
      for (var s = bottomStep - 2; s >= step; s -= 2) {
        final ly = yFor(s);
        canvas.drawLine(
          Offset(noteX - 12, ly),
          Offset(noteX + 12, ly),
          ledgerPaint,
        );
      }
    }

    // ── Tête de note ──────────────────────────────────────────────────────────
    // L'ovale est incliné de -22° (convention typographique musicale).
    canvas.save();
    canvas.translate(noteX, noteY);
    canvas.rotate(-22 * pi / 180);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2),
      Paint()..color = noteColor,
    );
    canvas.restore();

    // ── Hampe ─────────────────────────────────────────────────────────────────
    // Convention : hampe vers le bas si la note est dans la moitié haute
    // (step >= milieu de la portée = bottomStep + 4), vers le haut sinon.
    // La hampe part du bord de l'ovale (±rx) et mesure 3 * lineGap.
    final stemPaint = Paint()
      ..color = noteColor
      ..strokeWidth = 1.6;

    if (step >= bottomStep + 4) {
      // Hampe vers le bas : depuis le bord gauche de l'ovale.
      canvas.drawLine(
        Offset(noteX - rx, noteY + 1),
        Offset(noteX - rx, noteY + lineGap * 3),
        stemPaint,
      );
    } else {
      // Hampe vers le haut : depuis le bord droit de l'ovale.
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
