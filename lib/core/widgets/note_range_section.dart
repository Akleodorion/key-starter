import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/providers/notation_language_provider.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/widgets/note_stepper_control.dart';
import 'package:key_starter/core/widgets/staff_range_widget.dart';
import 'package:key_starter/core/widgets/ui_text.dart';

/// Section « Étendue » des réglages d'un exercice : la portée qui montre la
/// note la plus grave et la plus aiguë du tirage, et un réglage pour chacune.
/// Quand la largeur manque (police agrandie, écran étroit), le réglage « à »
/// passe sous le réglage « de ».
///
/// Contrat : la sous-classe fournit la clé et les deux bornes lues dans ses
/// réglages, et les quatre actions qui les déplacent ; [hint] peut être
/// redéfini quand l'exercice ne tire pas des notes.
///
/// ```dart
/// class FlashcardRangeSection extends NoteRangeSection {
///   const FlashcardRangeSection({super.key});
///
///   @override
///   ClefMode clef(WidgetRef ref) => ref.watch(flashcardSettingsProvider).clef;
///   // … minNoteStep, maxNoteStep et les quatre actions
/// }
/// ```
///
/// Voir aussi : [FlashcardRangeSection], [ChordTempoRangeSection]
abstract class NoteRangeSection extends ConsumerWidget {
  const NoteRangeSection({super.key});

  /// Consigne affichée sous le titre de la section.
  String get hint => 'choisis la note la plus grave et la plus aiguë';

  /// Clé de la portée sur laquelle l'étendue est dessinée.
  ClefMode clef(WidgetRef ref);

  /// Pas diatonique de la note la plus grave.
  int minNoteStep(WidgetRef ref);

  /// Pas diatonique de la note la plus aiguë.
  int maxNoteStep(WidgetRef ref);

  /// Descend la note la plus grave d'un pas.
  void decrementMinNote(WidgetRef ref);

  /// Monte la note la plus grave d'un pas.
  void incrementMinNote(WidgetRef ref);

  /// Descend la note la plus aiguë d'un pas.
  void decrementMaxNote(WidgetRef ref);

  /// Monte la note la plus aiguë d'un pas.
  void incrementMaxNote(WidgetRef ref);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorTheme.of(context);
    final language = ref.watch(notationLanguageProvider);
    final lowestStep = minNoteStep(ref);
    final highestStep = maxNoteStep(ref);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UiText(
          'Étendue',
          size: 15,
          weight: FontWeight.w600,
          color: colors.text,
        ),
        const SizedBox(height: 2),
        UiText(hint, size: 12, color: colors.text2),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.line),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: StaffRangeWidget(
                  clef: clef(ref),
                  minDiatonicStep: lowestStep,
                  maxDiatonicStep: highestStep,
                ),
              ),
              Divider(height: 1, thickness: 1, color: colors.line),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      NoteStepperControl(
                        label: 'de',
                        step: lowestStep,
                        language: language,
                        onDecrement: () => decrementMinNote(ref),
                        onIncrement: () => incrementMinNote(ref),
                      ),
                      NoteStepperControl(
                        label: 'à',
                        step: highestStep,
                        language: language,
                        onDecrement: () => decrementMaxNote(ref),
                        onIncrement: () => incrementMaxNote(ref),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
