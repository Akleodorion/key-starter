import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/presentation/widgets/segmented_picker.dart';
import 'package:key_starter/presentation/widgets/settings_row_label.dart';

/// Ligne de réglage à choix segmenté (ex: thème, langue, clef).
///
/// Affiche un [SettingsRowLabel] suivi d'un [SegmentedPicker] générique sur
/// [T]. Les sous-classes fournissent le label, les options disponibles, la
/// valeur sélectionnée et l'action de changement en implémentant [label],
/// [options], [selected] et [onChanged].
///
/// ```dart
/// class ThemeSettingsRow extends SettingsSegmentedRow<ThemeMode> {
///   const ThemeSettingsRow({super.key});
///
///   @override String get label => 'Thème';
///   @override List<(ThemeMode, String)> get options => const [
///     (ThemeMode.system, 'Auto'),
///     (ThemeMode.light, 'Clair'),
///     (ThemeMode.dark, 'Sombre'),
///   ];
///   @override ThemeMode selected(WidgetRef ref) => ref.watch(themeProvider);
///   @override void onChanged(WidgetRef ref, ThemeMode value) =>
///       ref.read(themeProvider.notifier).setMode(value);
/// }
/// ```
///
/// Voir aussi : [ThemeSettingsRow], [NotationSettingsRow], [FlashcardClefRow]
abstract class SettingsSegmentedRow<T> extends ConsumerWidget {
  const SettingsSegmentedRow({super.key});

  String get label;
  String? get description => null;
  List<(T, String)> get options;

  T selected(WidgetRef ref);
  void onChanged(WidgetRef ref, T value);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SettingsRowLabel(label: label, description: description),
          const SizedBox(width: 12),
          SegmentedPicker<T>(
            options: options,
            selected: selected(ref),
            onChanged: (value) => onChanged(ref, value),
          ),
        ],
      ),
    );
  }
}
