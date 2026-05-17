import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
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
      extensions: const [AppColorTheme.light],
      textTheme: TextTheme(
        displayLarge: AppTextStyles.display(size: 54, color: AppColors.text),
        displayMedium: AppTextStyles.display(size: 44, color: AppColors.text),
        displaySmall: AppTextStyles.display(size: 32, color: AppColors.text),
        headlineMedium: AppTextStyles.ui(size: 22, weight: FontWeight.w600, color: AppColors.text),
        headlineSmall: AppTextStyles.ui(size: 18, weight: FontWeight.w600, color: AppColors.text),
        titleMedium: AppTextStyles.ui(size: 16, weight: FontWeight.w500, color: AppColors.text),
        titleSmall: AppTextStyles.ui(size: 14, weight: FontWeight.w500, color: AppColors.text),
        bodyLarge: AppTextStyles.ui(size: 16, color: AppColors.text),
        bodyMedium: AppTextStyles.ui(size: 14, color: AppColors.text),
        bodySmall: AppTextStyles.ui(size: 12, color: AppColors.text2),
        labelLarge: AppTextStyles.ui(size: 15, weight: FontWeight.w600, color: AppColors.text),
        labelSmall: AppTextStyles.label(color: AppColors.text3),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.text,
        titleTextStyle: AppTextStyles.ui(size: 16, weight: FontWeight.w600, color: AppColors.text),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 0,
      ),
    );
  }

  static ThemeData dark() {
    const colors = AppColorTheme.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colors.bg,
      colorScheme: ColorScheme.dark(
        primary: AppColors.notesFg,
        onPrimary: Colors.white,
        surface: colors.surface,
        onSurface: colors.text,
        error: AppColors.stateRed,
        onError: Colors.white,
      ),
      extensions: const [AppColorTheme.dark],
      textTheme: TextTheme(
        displayLarge: AppTextStyles.display(size: 54, color: colors.text),
        displayMedium: AppTextStyles.display(size: 44, color: colors.text),
        displaySmall: AppTextStyles.display(size: 32, color: colors.text),
        headlineMedium: AppTextStyles.ui(size: 22, weight: FontWeight.w600, color: colors.text),
        headlineSmall: AppTextStyles.ui(size: 18, weight: FontWeight.w600, color: colors.text),
        titleMedium: AppTextStyles.ui(size: 16, weight: FontWeight.w500, color: colors.text),
        titleSmall: AppTextStyles.ui(size: 14, weight: FontWeight.w500, color: colors.text),
        bodyLarge: AppTextStyles.ui(size: 16, color: colors.text),
        bodyMedium: AppTextStyles.ui(size: 14, color: colors.text),
        bodySmall: AppTextStyles.ui(size: 12, color: colors.text2),
        labelLarge: AppTextStyles.ui(size: 15, weight: FontWeight.w600, color: colors.text),
        labelSmall: AppTextStyles.label(color: colors.text3),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: colors.text,
        titleTextStyle: AppTextStyles.ui(size: 16, weight: FontWeight.w600, color: colors.text),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      dividerTheme: DividerThemeData(
        color: colors.line,
        thickness: 1,
        space: 0,
      ),
    );
  }
}
