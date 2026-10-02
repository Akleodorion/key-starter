import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/providers/app_settings_datasource_provider.dart';

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.read(appSettingsLocalDataSourceProvider).themeMode;

  void setMode(ThemeMode mode) {
    state = mode;
    ref.read(appSettingsLocalDataSourceProvider).saveThemeMode(mode);
  }
}
