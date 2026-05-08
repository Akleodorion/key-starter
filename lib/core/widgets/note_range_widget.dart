import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/enums/note_range_bound.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/widgets/note_control.dart';
import 'package:key_starter/core/widgets/staff_range_widget.dart';

/// Widget abstrait de sélection de plage de notes (MIN / MAX).
///
/// Définit l'UI complète. Les sous-classes fournissent les données
/// et les actions en implémentant les méthodes abstraites.
abstract class NoteRangeWidget extends ConsumerWidget {
  const NoteRangeWidget({super.key});

  ClefMode clef(WidgetRef ref);
  int minStep(WidgetRef ref);
  int maxStep(WidgetRef ref);
  NoteLanguage language(WidgetRef ref);
  void onMinChanged(WidgetRef ref, int step);
  void onMaxChanged(WidgetRef ref, int step);

  static const _minStepByClef = {
    ClefMode.treble: -3, // Sol 3
    ClefMode.bass: -17, // Sol 1
  };
  static const _maxStepByClef = {
    ClefMode.treble: 15, // Ré 6
    ClefMode.bass: 3, // Fa 4
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentClef = clef(ref);
    final currentMinStep = minStep(ref);
    final currentMaxStep = maxStep(ref);
    final currentLanguage = language(ref);

    final minControl = NoteControl(
      bound: NoteRangeBound.min,
      step: currentMinStep,
      lang: currentLanguage,
      lowerLimit: _minStepByClef[currentClef]!,
      upperLimit: currentMaxStep - 1,
      onChanged: (step) => onMinChanged(ref, step),
    );
    final maxControl = NoteControl(
      bound: NoteRangeBound.max,
      step: currentMaxStep,
      lang: currentLanguage,
      lowerLimit: currentMinStep + 1,
      upperLimit: _maxStepByClef[currentClef]!,
      onChanged: (step) => onMaxChanged(ref, step),
    );
    final staff = StaffRangeWidget(
      clef: currentClef,
      minDiatonicStep: currentMinStep,
      maxDiatonicStep: currentMaxStep,
      height: 100,
    );
    final divider = VerticalDivider(
      width: 1,
      thickness: 1,
      color: AppColors.lineStrong,
    );

    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    if (isLandscape) {
      return IntrinsicHeight(
        child: Row(
          children: [
            Expanded(flex: 2, child: minControl),
            divider,
            Expanded(flex: 2, child: maxControl),
            divider,
            Expanded(
              flex: 8,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: staff,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(child: minControl),
              divider,
              Expanded(child: maxControl),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 56),
          child: staff,
        ),
      ],
    );
  }
}
