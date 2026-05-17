import 'package:flutter/material.dart';
import 'package:key_starter/presentation/widgets/settings_row_label.dart';

class SettingsToggleRow extends StatelessWidget {
  final String label;
  final String? description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsToggleRow({
    super.key,
    required this.label,
    this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SettingsRowLabel(label: label, description: description),
          const SizedBox(width: 12),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
