import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/presentation/widgets/segmented_picker.dart';
import 'package:key_starter/presentation/widgets/settings_row_label.dart';

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
