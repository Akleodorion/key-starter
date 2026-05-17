import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/providers/notation_language_provider.dart';
import 'package:key_starter/presentation/widgets/settings_segmented_row.dart';

/// Implémentation de [SettingsSegmentedRow] liée à [notationLanguageProvider].
class NotationSettingsRow extends SettingsSegmentedRow<NoteLanguage> {
  const NotationSettingsRow({super.key});

  @override
  String get label => 'Notation';

  @override
  String? get description => 'Do Ré Mi · C D E';

  @override
  List<(NoteLanguage, String)> get options => const [
    (NoteLanguage.fr, 'Fr'),
    (NoteLanguage.en, 'EN'),
  ];

  @override
  NoteLanguage selected(WidgetRef ref) => ref.watch(notationLanguageProvider);

  @override
  void onChanged(WidgetRef ref, NoteLanguage value) =>
      ref.read(notationLanguageProvider.notifier).setLanguage(value);
}
