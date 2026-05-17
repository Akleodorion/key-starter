import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';
import 'package:key_starter/presentation/widgets/settings_section_data.dart';

class SettingsSection extends StatelessWidget {
  final SettingsSectionData section;

  const SettingsSection({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(section.title.toUpperCase(), style: AppTextStyles.label()),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: section.children),
        ),
      ],
    );
  }
}
