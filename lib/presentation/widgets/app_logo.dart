import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.text,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Center(
        child: Text(
          '◐',
          style: AppTextStyles.ui(
            size: 15,
            weight: FontWeight.w700,
            color: AppColors.surface,
          ),
        ),
      ),
    );
  }
}
