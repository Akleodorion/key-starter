import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.ivory,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accent,
        onPrimary: Colors.white,
        surface: AppColors.paper,
        onSurface: AppColors.ink,
        error: AppColors.err,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        // Grands titres → display
        displayLarge: AppTextStyles.display(size: 54),
        displayMedium: AppTextStyles.display(size: 36),
        displaySmall: AppTextStyles.display(size: 28),
        // Titres courants → UI
        headlineMedium: AppTextStyles.ui(size: 22, weight: FontWeight.w600),
        headlineSmall: AppTextStyles.ui(size: 18, weight: FontWeight.w600),
        titleMedium: AppTextStyles.ui(size: 16, weight: FontWeight.w500),
        titleSmall: AppTextStyles.ui(size: 14, weight: FontWeight.w500),
        // Corps
        bodyLarge: AppTextStyles.ui(size: 16),
        bodyMedium: AppTextStyles.ui(size: 14),
        bodySmall: AppTextStyles.ui(size: 12, color: AppColors.inkSoft),
        // Labels
        labelLarge: AppTextStyles.ui(size: 15, weight: FontWeight.w600),
        labelSmall: AppTextStyles.eyebrow(),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.ivory,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.ink,
        titleTextStyle: AppTextStyles.ui(size: 16, weight: FontWeight.w600),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 0,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.accent,
        inactiveTrackColor: AppColors.lineStrong,
        thumbColor: Colors.white,
        overlayColor: AppColors.accent.withValues(alpha: 0.12),
        trackHeight: 6,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
      ),
    );
  }
}
