import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/defilement_settings_notifier.dart';
import 'package:key_starter/presentation/widgets/settings_stepper_row.dart';

/// Implémentation de [SettingsStepperRow] liée à [defilementSettingsProvider].
class DefilementNoteCountRow extends SettingsStepperRow {
  const DefilementNoteCountRow({super.key});

  @override
  String get label => 'Nombre de notes';

  @override
  int value(WidgetRef ref) => ref.watch(defilementSettingsProvider).noteCount;

  @override
  void onDecrement(WidgetRef ref) =>
      ref.read(defilementSettingsProvider.notifier).decrementNoteCount();

  @override
  void onIncrement(WidgetRef ref) =>
      ref.read(defilementSettingsProvider.notifier).incrementNoteCount();
}
