import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/utils/staff_paint_utils.dart';

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

    return SizedBox(
      height: height,
      width: staffwidth ?? double.infinity,
      child: CustomPaint(
        painter: _StaffPainter(
          clef: clef(ref),
          diatonicStep: diatonicStep(ref),
          state: noteState(ref),
          lineColor: lineColor,
        ),
      ),
    );
  }
}

/// Dessine la portée, le glyphe de clef et la note sur un [Canvas], via les
/// fonctions partagées de `staff_paint_utils.dart`.
class _StaffPainter extends CustomPainter {
  final ClefMode clef;
  final int? diatonicStep;
  final NoteState state;
  final Color lineColor;

  const _StaffPainter({
    required this.clef,
    required this.diatonicStep,
    required this.state,
    required this.lineColor,
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

    final step = diatonicStep;
    if (step == null) return;

    final noteColor = switch (state) {
      NoteState.correct => AppColors.stateGreen,
      NoteState.wrong => AppColors.stateRed,
      NoteState.idle => lineColor,
    };
    // La note est centrée horizontalement, décalée à droite de la clef.
    paintNote(
      canvas,
      noteX: size.width / 2 + 30,
      step: step,
      clef: clef,
      staffTop: staffTop,
      color: noteColor,
    );
  }

  @override
  bool shouldRepaint(_StaffPainter old) =>
      old.clef != clef ||
      old.diatonicStep != diatonicStep ||
      old.state != state ||
      old.lineColor != lineColor;
}
