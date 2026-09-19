import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/presentation/widgets/settings_row_label.dart';

/// Ligne de réglage avec un switch on/off.
///
/// Affiche un [SettingsRowLabel] (label + description optionnelle) suivi
/// d'un [Switch] Material. Les sous-classes fournissent le label, la valeur
/// courante et l'action de changement en implémentant [label], [value] et
/// [onChanged].
///
/// ```dart
/// class NoteAidToggleRow extends SettingsToggleRow {
///   const NoteAidToggleRow({super.key});
///
///   @override String get label => 'Aide : nom des notes';
///   @override bool value(WidgetRef ref) => ref.watch(showNoteAidProvider);
///   @override void onChanged(WidgetRef ref, bool value) =>
///       ref.read(showNoteAidProvider.notifier).setValue(value);
/// }
/// ```
///
/// Voir aussi : [NoteAidToggleRow]
abstract class SettingsToggleRow extends ConsumerWidget {
  const SettingsToggleRow({super.key});

  String get label;
  String? get description => null;

  bool value(WidgetRef ref);
  void onChanged(WidgetRef ref, bool value);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SettingsRowLabel(label: label, description: description),
          const SizedBox(width: 12),
          Switch(value: value(ref), onChanged: (v) => onChanged(ref, v)),
        ],
      ),
    );
  }
}
