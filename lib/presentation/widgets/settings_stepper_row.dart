import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/widgets/secondary_icon_button.dart';
import 'package:key_starter/core/widgets/ui_text.dart';
import 'package:key_starter/presentation/widgets/settings_row_label.dart';

abstract class SettingsStepperRow extends ConsumerWidget {
  const SettingsStepperRow({super.key});

  String get label;
  String? get description => null;
  int value(WidgetRef ref);
  void onDecrement(WidgetRef ref);
  void onIncrement(WidgetRef ref);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorTheme.of(context);
    final currentValue = value(ref);

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
            currentValue.toString(),
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
