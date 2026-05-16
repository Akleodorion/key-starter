import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.notesFg,
        onPrimary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.text,
        error: AppColors.stateRed,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.display(size: 54),
        displayMedium: AppTextStyles.display(size: 44),
        displaySmall: AppTextStyles.display(size: 32),
        headlineMedium: AppTextStyles.ui(size: 22, weight: FontWeight.w600),
        headlineSmall: AppTextStyles.ui(size: 18, weight: FontWeight.w600),
        titleMedium: AppTextStyles.ui(size: 16, weight: FontWeight.w500),
        titleSmall: AppTextStyles.ui(size: 14, weight: FontWeight.w500),
        bodyLarge: AppTextStyles.ui(size: 16),
        bodyMedium: AppTextStyles.ui(size: 14),
        bodySmall: AppTextStyles.ui(size: 12, color: AppColors.text2),
        labelLarge: AppTextStyles.ui(size: 15, weight: FontWeight.w600),
        labelSmall: AppTextStyles.label(),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.text,
        titleTextStyle: AppTextStyles.ui(size: 16, weight: FontWeight.w600),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 0,
      ),
    );
  }
}
