import 'package:flutter/material.dart';
import 'package:key_starter/presentation/widgets/settings_section_data.dart';
import 'package:key_starter/presentation/widgets/theme_settings_row.dart';

class ThemeSection extends SettingsSectionData {
  const ThemeSection();

  @override
  String get title => 'Apparence';

  @override
  List<Widget> get children => const [ThemeSettingsRow()];
}
