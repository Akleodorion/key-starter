import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/widgets/secondary_icon_button.dart';
import 'package:key_starter/core/widgets/ui_text.dart';
import 'package:key_starter/presentation/widgets/settings_row_label.dart';

/// Ligne de réglage à boutons +/- dont la valeur s'affiche en texte libre
/// (« Libre », « 60 »…).
///
/// Affiche un [SettingsRowLabel] suivi d'un décrémenteur, de la valeur
/// courante et d'un incrémenteur. Les sous-classes fournissent le label, le
/// texte de la valeur et les actions +/- en implémentant [label],
/// [valueText], [onDecrement] et [onIncrement].
///
/// ```dart
/// class SongTempoRow extends SettingsTextStepperRow {
///   const SongTempoRow({super.key});
///
///   @override String get label => 'Tempo';
///   @override String valueText(WidgetRef ref) =>
///       ref.watch(songTempoProvider)?.toString() ?? 'Libre';
///   @override void onDecrement(WidgetRef ref) =>
///       ref.read(songTempoProvider.notifier).decrement();
///   @override void onIncrement(WidgetRef ref) =>
///       ref.read(songTempoProvider.notifier).increment();
/// }
/// ```
///
/// Voir aussi : [SongTempoRow], et [SettingsStepperRow] pour une valeur
/// entière.
abstract class SettingsTextStepperRow extends ConsumerWidget {
  const SettingsTextStepperRow({super.key});

  String get label;
  String? get description => null;

  /// Texte affiché entre les deux boutons.
  String valueText(WidgetRef ref);
  void onDecrement(WidgetRef ref);
  void onIncrement(WidgetRef ref);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SettingsRowLabel(label: label, description: description),
          const SizedBox(width: 12),
          SecondaryIconButton(
            icon: Icons.remove_rounded,
            color: colors.text,
            onTap: () => onDecrement(ref),
          ),
          const SizedBox(width: 12),
          UiText(
            valueText(ref),
            size: 15,
            weight: FontWeight.w600,
            color: colors.text,
          ),
          const SizedBox(width: 12),
          SecondaryIconButton(
            icon: Icons.add_rounded,
            color: colors.text,
            onTap: () => onIncrement(ref),
          ),
        ],
      ),
    );
  }
}
