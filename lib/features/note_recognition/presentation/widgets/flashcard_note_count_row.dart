import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/flashcard_settings_notifier.dart';
import 'package:key_starter/presentation/widgets/settings_stepper_row.dart';

/// Implémentation de [SettingsStepperRow] liée à [flashcardSettingsProvider].
class FlashcardNoteCountRow extends SettingsStepperRow {
  const FlashcardNoteCountRow({super.key});

  @override
  String get label => 'Nombre de notes';

  @override
  int value(WidgetRef ref) => ref.watch(flashcardSettingsProvider).noteCount;

  @override
  void onDecrement(WidgetRef ref) =>
      ref.read(flashcardSettingsProvider.notifier).decrementNoteCount();

  @override
  void onIncrement(WidgetRef ref) =>
      ref.read(flashcardSettingsProvider.notifier).incrementNoteCount();
}
