import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_colors.dart';

class AppColorTheme extends ThemeExtension<AppColorTheme> {
  final Color bg;
  final Color bgInset;
  final Color surface;
  final Color surfaceMuted;
  final Color line;
  final Color lineSoft;
  final Color text;
  final Color text2;
  final Color text3;
  final Color text4;
  final Color notesTint;
  final Color chordsTint;
  final Color intervalsTint;

  const AppColorTheme({
    required this.bg,
    required this.bgInset,
    required this.surface,
    required this.surfaceMuted,
    required this.line,
    required this.lineSoft,
    required this.text,
    required this.text2,
    required this.text3,
    required this.text4,
    required this.notesTint,
    required this.chordsTint,
    required this.intervalsTint,
  });

  static AppColorTheme of(BuildContext context) =>
      Theme.of(context).extension<AppColorTheme>()!;

  static const light = AppColorTheme(
    bg: AppColors.bg,
    bgInset: AppColors.bgInset,
    surface: AppColors.surface,
    surfaceMuted: AppColors.surfaceMuted,
    line: AppColors.line,
    lineSoft: AppColors.lineSoft,
    text: AppColors.text,
    text2: AppColors.text2,
    text3: AppColors.text3,
    text4: AppColors.text4,
    notesTint: AppColors.notesTint,
    chordsTint: AppColors.chordsTint,
    intervalsTint: AppColors.intervalsTint,
  );

  static const dark = AppColorTheme(
    bg: Color(0xFF0C0C0D),
    bgInset: Color(0xFF161617),
    surface: Color(0xFF1A1A1B),
    surfaceMuted: Color(0xFF141415),
    line: Color(0xFF2A2A2B),
    lineSoft: Color(0xFF222223),
    text: Color(0xFFF4F3EE),
    text2: Color(0xFF9B9AA0),
    text3: Color(0xFF4A4950),
    text4: Color(0xFF363540),
    notesTint: Color(0xFF1C2550),
    chordsTint: Color(0xFF3A1C10),
    intervalsTint: Color(0xFF0E3025),
  );

  @override
  AppColorTheme copyWith({
    Color? bg,
    Color? bgInset,
    Color? surface,
    Color? surfaceMuted,
    Color? line,
    Color? lineSoft,
    Color? text,
    Color? text2,
    Color? text3,
    Color? text4,
    Color? notesTint,
    Color? chordsTint,
    Color? intervalsTint,
  }) {
    return AppColorTheme(
      bg: bg ?? this.bg,
      bgInset: bgInset ?? this.bgInset,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      line: line ?? this.line,
      lineSoft: lineSoft ?? this.lineSoft,
      text: text ?? this.text,
      text2: text2 ?? this.text2,
      text3: text3 ?? this.text3,
      text4: text4 ?? this.text4,
      notesTint: notesTint ?? this.notesTint,
      chordsTint: chordsTint ?? this.chordsTint,
      intervalsTint: intervalsTint ?? this.intervalsTint,
    );
  }

  @override
  AppColorTheme lerp(AppColorTheme? other, double t) {
    if (other is! AppColorTheme) return this;
    return AppColorTheme(
      bg: Color.lerp(bg, other.bg, t)!,
      bgInset: Color.lerp(bgInset, other.bgInset, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      line: Color.lerp(line, other.line, t)!,
      lineSoft: Color.lerp(lineSoft, other.lineSoft, t)!,
      text: Color.lerp(text, other.text, t)!,
      text2: Color.lerp(text2, other.text2, t)!,
      text3: Color.lerp(text3, other.text3, t)!,
      text4: Color.lerp(text4, other.text4, t)!,
      notesTint: Color.lerp(notesTint, other.notesTint, t)!,
      chordsTint: Color.lerp(chordsTint, other.chordsTint, t)!,
      intervalsTint: Color.lerp(intervalsTint, other.intervalsTint, t)!,
    );
  }
}
