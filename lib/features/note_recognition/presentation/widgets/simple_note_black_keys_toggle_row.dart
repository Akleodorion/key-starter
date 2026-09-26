import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/simple_note_black_keys_notifier.dart';
import 'package:key_starter/presentation/widgets/settings_toggle_row.dart';

/// Implémentation de [SettingsToggleRow] liée à [simpleNoteBlackKeysProvider].
class SimpleNoteBlackKeysToggleRow extends SettingsToggleRow {
  const SimpleNoteBlackKeysToggleRow({super.key});

  @override
  String get label => 'Touches noires';

  @override
  String? get description => 'inclut les dièses (Do♯, Fa♯…)';

  @override
  bool value(WidgetRef ref) => ref.watch(simpleNoteBlackKeysProvider);

  @override
  void onChanged(WidgetRef ref, bool value) =>
      ref.read(simpleNoteBlackKeysProvider.notifier).setValue(value);
}
