import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/providers/show_note_aid_provider.dart';
import 'package:key_starter/presentation/widgets/settings_toggle_row.dart';

/// Implémentation de [SettingsToggleRow] liée à [showNoteAidProvider].
class NoteAidToggleRow extends SettingsToggleRow {
  const NoteAidToggleRow({super.key});

  @override
  String get label => 'Aide : nom des notes';

  @override
  String? get description => 'petit label sous chaque note';

  @override
  bool value(WidgetRef ref) => ref.watch(showNoteAidProvider);

  @override
  void onChanged(WidgetRef ref, bool value) =>
      ref.read(showNoteAidProvider.notifier).setValue(value);
}
