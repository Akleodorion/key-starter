import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/presentation/widgets/settings_stepper_layout.dart';

/// Ligne de réglage numérique avec boutons +/-.
///
/// Affiche un [SettingsRowLabel] suivi d'un décrémenteur, de la valeur
/// courante et d'un incrémenteur. Les sous-classes fournissent le label, la
/// valeur courante et les actions +/- en implémentant [label], [value],
/// [onDecrement] et [onIncrement].
///
/// ```dart
/// class FlashcardNoteCountRow extends SettingsStepperRow {
///   const FlashcardNoteCountRow({super.key});
///
///   @override String get label => 'Nombre de notes';
///   @override int value(WidgetRef ref) =>
///       ref.watch(flashcardSettingsProvider).noteCount;
///   @override void onDecrement(WidgetRef ref) =>
///       ref.read(flashcardSettingsProvider.notifier).decrementNoteCount();
///   @override void onIncrement(WidgetRef ref) =>
///       ref.read(flashcardSettingsProvider.notifier).incrementNoteCount();
/// }
/// ```
///
/// Voir aussi : [FlashcardNoteCountRow]
abstract class SettingsStepperRow extends ConsumerWidget {
  const SettingsStepperRow({super.key});

  String get label;
  String? get description => null;
  int value(WidgetRef ref);
  void onDecrement(WidgetRef ref);
  void onIncrement(WidgetRef ref);

  @override
  Widget build(BuildContext context, WidgetRef ref) => SettingsStepperLayout(
    label: label,
    description: description,
    valueText: value(ref).toString(),
    onDecrement: () => onDecrement(ref),
    onIncrement: () => onIncrement(ref),
  );
}
