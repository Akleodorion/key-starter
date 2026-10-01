import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/chord_inversion_choice.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/chord_inversion_choice_notifier.dart';
import 'package:key_starter/presentation/widgets/settings_segmented_row.dart';

/// Implémentation de [SettingsSegmentedRow] liée à [chordInversionChoiceProvider].
class ChordInversionChoiceRow
    extends SettingsSegmentedRow<ChordInversionChoice> {
  const ChordInversionChoiceRow({super.key});

  @override
  String get label => 'Renversements';

  @override
  List<(ChordInversionChoice, String)> get options => const [
    (ChordInversionChoice.first, '1er'),
    (ChordInversionChoice.second, '2e'),
    (ChordInversionChoice.both, 'Les deux'),
  ];

  @override
  double get segmentWidth => 72.0;

  @override
  ChordInversionChoice selected(WidgetRef ref) =>
      ref.watch(chordInversionChoiceProvider);

  @override
  void onChanged(WidgetRef ref, ChordInversionChoice value) =>
      ref.read(chordInversionChoiceProvider.notifier).setValue(value);
}
