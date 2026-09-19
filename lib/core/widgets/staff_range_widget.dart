import 'package:flutter/material.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/utils/staff_paint_utils.dart';

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
    final lineColor = AppColorTheme.of(context).text;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _StaffRangePainter(
          clef: clef,
          minDiatonicStep: minDiatonicStep,
          maxDiatonicStep: maxDiatonicStep,
          lineColor: lineColor,
        ),
      ),
    );
  }
}

class _StaffRangePainter extends CustomPainter {
  final ClefMode clef;
  final int minDiatonicStep;
  final int maxDiatonicStep;
  final Color lineColor;

  const _StaffRangePainter({
    required this.clef,
    required this.minDiatonicStep,
    required this.maxDiatonicStep,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final staffTop = staffTopFor(size);
    final noteX = size.width / 2 + 30;

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

    // ── Note min — note max ─────────────────────────────────────────────
    const noteSpacing = 40.0;
    paintNote(
      canvas,
      noteX: noteX - noteSpacing,
      step: minDiatonicStep,
      clef: clef,
      staffTop: staffTop,
      color: AppColors.notesFg,
    );
    paintNote(
      canvas,
      noteX: noteX + noteSpacing,
      step: maxDiatonicStep,
      clef: clef,
      staffTop: staffTop,
      color: AppColors.notesFg,
    );
  }

  @override
  bool shouldRepaint(_StaffRangePainter old) =>
      old.clef != clef ||
      old.minDiatonicStep != minDiatonicStep ||
      old.maxDiatonicStep != maxDiatonicStep ||
      old.lineColor != lineColor;
}
