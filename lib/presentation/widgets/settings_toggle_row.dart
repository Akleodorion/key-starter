import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/presentation/widgets/settings_row_label.dart';

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
