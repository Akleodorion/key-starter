import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/presentation/widgets/settings_text_stepper_row.dart';

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
abstract class SettingsStepperRow extends SettingsTextStepperRow {
  const SettingsStepperRow({super.key});

  int value(WidgetRef ref);

  @override
  String valueText(WidgetRef ref) => value(ref).toString();
}
