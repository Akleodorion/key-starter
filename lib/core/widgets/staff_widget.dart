import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/utils/note_feedback_motion.dart';
import 'package:key_starter/core/utils/staff_paint_utils.dart';
import 'package:key_starter/core/widgets/note_feedback_motion.dart';

/// Widget abstrait de portée musicale avec note positionnée.
///
/// Dessine une portée à 5 lignes, le glyphe de clef (Sol ou Fa) et,
/// si [diatonicStep] est non-null, la note correspondante colorée selon
/// [noteState]. Les lignes supplémentaires sont ajoutées automatiquement.
/// Une note qui vient d'être jugée gonfle (juste) ou tremble (fausse).
///
/// Les sous-classes fournissent la clef, le degré diatonique et l'état
/// de la note en implémentant [clef], [diatonicStep] et [noteState].
///
/// ```dart
/// class FlashcardStaffWidget extends StaffWidget {
///   final NoteExerciseSettings settings;
///   const FlashcardStaffWidget({super.key, required this.settings, super.height});
///
///   @override ClefMode clef(WidgetRef ref) => settings.clef;
///   @override int? diatonicStep(WidgetRef ref) => _runningExercise(ref)?.currentStep;
///   @override NoteState noteState(WidgetRef ref) { ... }
/// }
/// ```
///
/// Voir aussi : [FlashcardStaffWidget]
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
    final lineColor = AppColorTheme.of(context).text;
    final currentClef = clef(ref);
    final currentStep = diatonicStep(ref);
    final currentNoteState = noteState(ref);

    return SizedBox(
      height: height,
      width: staffwidth ?? double.infinity,
      child: NoteFeedbackMotion(
        noteState: currentNoteState,
        duration: noteAdvanceDelay,
        builder: (context, noteScale, noteShift) => CustomPaint(
          painter: StaffPainter(
            clef: currentClef,
            diatonicStep: currentStep,
            state: currentNoteState,
            lineColor: lineColor,
            noteScale: noteScale,
            noteShift: noteShift,
          ),
        ),
      ),
    );
  }
}

/// Dessine la portée, le glyphe de clef et la note (avec son échelle et son
/// décalage horizontal) sur un [Canvas], via les fonctions partagées de
/// `staff_paint_utils.dart`.
class StaffPainter extends CustomPainter {
  final ClefMode clef;
  final int? diatonicStep;
  final NoteState state;
  final Color lineColor;
  final double noteScale;
  final double noteShift;

  const StaffPainter({
    required this.clef,
    required this.diatonicStep,
    required this.state,
    required this.lineColor,
    this.noteScale = 1,
    this.noteShift = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // L'échelle suit la hauteur du widget : 100 px redonnent l'écart par défaut.
    final lineGap = staffLineGapForHeight(size.height);
    final staffTop = staffTopFor(size, lineGap: lineGap);

    paintStaffLines(
      canvas,
      staffTop: staffTop,
      x1: lineGap * 2,
      x2: size.width - lineGap * 2,
      lineColor: lineColor,
      lineGap: lineGap,
    );
    paintClefGlyph(
      canvas,
      clef: clef,
      x: lineGap * 2.2,
      staffTop: staffTop,
      color: lineColor,
      lineGap: lineGap,
    );

    final step = diatonicStep;
    if (step == null) return;

    final noteColor = switch (state) {
      NoteState.correct => AppColors.stateGreen,
      NoteState.wrong => AppColors.stateRed,
      NoteState.idle => lineColor,
    };
    // La note est centrée horizontalement, décalée à droite de la clef.
    final noteX = size.width / 2 + lineGap * 3;
    final noteY = staffYFor(
      step,
      clef: clef,
      staffTop: staffTop,
      lineGap: lineGap,
    );
    canvas.save();
    canvas.translate(noteX + noteShift, noteY);
    canvas.scale(noteScale);
    canvas.translate(-noteX, -noteY);
    paintNote(
      canvas,
      noteX: noteX,
      step: step,
      clef: clef,
      staffTop: staffTop,
      color: noteColor,
      lineGap: lineGap,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(StaffPainter old) =>
      old.noteScale != noteScale ||
      old.noteShift != noteShift ||
      old.clef != clef ||
      old.diatonicStep != diatonicStep ||
      old.state != state ||
      old.lineColor != lineColor;
}
