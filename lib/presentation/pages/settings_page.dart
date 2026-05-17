import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/presentation/widgets/settings_section.dart';
import 'package:key_starter/presentation/widgets/settings_top_bar.dart';
import 'package:key_starter/presentation/widgets/theme_section.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SettingsTopBar(),
              const SizedBox(height: 32),
              const SettingsSection(section: ThemeSection()),
            ],
          ),
        ),
      ),
    );
  }
}
