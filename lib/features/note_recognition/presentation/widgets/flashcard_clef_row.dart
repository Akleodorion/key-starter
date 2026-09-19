import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/flashcard_settings_notifier.dart';
import 'package:key_starter/presentation/widgets/settings_segmented_row.dart';

/// Implémentation de [SettingsSegmentedRow] liée à [flashcardSettingsProvider].
class FlashcardClefRow extends SettingsSegmentedRow<ClefMode> {
  const FlashcardClefRow({super.key});

  @override
  String get label => 'Clé';

  @override
  String? description(WidgetRef ref) => 'une clé à la fois';

  @override
  List<(ClefMode, String)> get options => const [
    (ClefMode.treble, 'Sol'),
    (ClefMode.bass, 'Fa'),
  ];

  @override
  ClefMode selected(WidgetRef ref) => ref.watch(flashcardSettingsProvider).clef;

  @override
  void onChanged(WidgetRef ref, ClefMode value) =>
      ref.read(flashcardSettingsProvider.notifier).setClef(value);
}
