import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/tempo_bpm_notifier.dart';
import 'package:key_starter/presentation/widgets/settings_stepper_row.dart';

/// Implémentation de [SettingsStepperRow] liée à [tempoBpmProvider].
class TempoBpmRow extends SettingsStepperRow {
  const TempoBpmRow({super.key});

  @override
  String get label => 'Tempo';

  @override
  String? get description => 'battements par minute';

  @override
  int value(WidgetRef ref) => ref.watch(tempoBpmProvider);

  @override
  void onDecrement(WidgetRef ref) =>
      ref.read(tempoBpmProvider.notifier).decrement();

  @override
  void onIncrement(WidgetRef ref) =>
      ref.read(tempoBpmProvider.notifier).increment();
}
