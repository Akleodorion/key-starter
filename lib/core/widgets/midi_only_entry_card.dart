import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/input/input_source_kind.dart';
import 'package:key_starter/core/input/input_source_provider.dart';
import 'package:key_starter/core/models/card_entry.dart';
import 'package:key_starter/core/utils/feedback_utils.dart';
import 'package:key_starter/core/widgets/entry_card.dart';

/// [EntryCard] d'un exercice réservé au MIDI (accords, tempo) : atténuée sans
/// clavier connecté, elle invite alors à en brancher un au lieu de s'ouvrir.
class MidiOnlyEntryCard extends ConsumerWidget {
  static const midiRequiredMessage =
      'Branchez un clavier MIDI pour cet exercice.';

  final CardEntry entry;
  final VoidCallback onTap;

  const MidiOnlyEntryCard({
    super.key,
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMidiConnected =
        ref.watch(activeInputSourceKindProvider) == InputSourceKind.midi;
    return EntryCard(
      entry: entry,
      isDimmed: !isMidiConnected,
      onTap: isMidiConnected
          ? onTap
          : () => showToast(context, midiRequiredMessage),
    );
  }
}
