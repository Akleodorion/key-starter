import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';
import 'package:key_starter/presentation/widgets/settings_section_data.dart';

class SettingsSection extends StatelessWidget {
  final SettingsSectionData section;

  const SettingsSection({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(section.title.toUpperCase(), style: AppTextStyles.label(color: colors.text3)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.line),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              for (int i = 0; i < section.children.length; i++) ...[
                section.children[i],
                if (i < section.children.length - 1)
                  Divider(height: 1, thickness: 1, color: colors.line),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
