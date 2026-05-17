import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';

class SettingsRowLabel extends StatelessWidget {
  final String label;
  final String? description;

  const SettingsRowLabel({
    super.key,
    required this.label,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.ui(size: 15, weight: FontWeight.w600, color: colors.text)),
          if (description != null) ...[
            const SizedBox(height: 2),
            Text(
              description!,
              style: AppTextStyles.ui(size: 12, color: colors.text2),
            ),
          ],
        ],
      ),
    );
  }
}
