import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';
import 'package:key_starter/presentation/widgets/app_logo.dart';

class AppBrand extends StatelessWidget {
  const AppBrand({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppLogo(),
        const SizedBox(width: 8),
        Text(
          'Key',
          style: AppTextStyles.ui(size: 17, weight: FontWeight.w700, color: colors.text),
        ),
      ],
    );
  }
}
