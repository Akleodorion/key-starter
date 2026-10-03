import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/widgets/secondary_icon_button.dart';
import 'package:key_starter/core/widgets/ui_text.dart';
import 'package:key_starter/presentation/widgets/settings_row_label.dart';

/// Mise en page d'une ligne de réglage à boutons +/- : label, décrémenteur,
/// valeur affichée telle quelle, incrémenteur.
class SettingsStepperLayout extends StatelessWidget {
  final String label;
  final String? description;
  final String valueText;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const SettingsStepperLayout({
    super.key,
    required this.label,
    required this.description,
    required this.valueText,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
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
            onTap: onDecrement,
          ),
          const SizedBox(width: 12),
          UiText(
            valueText,
            size: 15,
            weight: FontWeight.w600,
            color: colors.text,
          ),
          const SizedBox(width: 12),
          SecondaryIconButton(
            icon: Icons.add_rounded,
            color: colors.text,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }
}
