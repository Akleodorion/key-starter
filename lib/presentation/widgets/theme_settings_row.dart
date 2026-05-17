import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/providers/theme_provider.dart';
import 'package:key_starter/presentation/widgets/settings_segmented_row.dart';

/// Implémentation de [SettingsSegmentedRow] liée à [themeProvider].
class ThemeSettingsRow extends SettingsSegmentedRow<ThemeMode> {
  const ThemeSettingsRow({super.key});

  @override
  String get label => 'Thème';

  @override
  String? get description => 'Auto suit ton appareil';

  @override
  List<(ThemeMode, String)> get options => const [
    (ThemeMode.system, 'Auto'),
    (ThemeMode.light, 'Clair'),
    (ThemeMode.dark, 'Sombre'),
  ];

  @override
  ThemeMode selected(WidgetRef ref) => ref.watch(themeProvider);

  @override
  void onChanged(WidgetRef ref, ThemeMode value) =>
      ref.read(themeProvider.notifier).setMode(value);
}
