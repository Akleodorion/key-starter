import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTextStyles {
  static TextStyle display({
    double size = 44,
    Color? color,
    FontWeight weight = FontWeight.w600,
  }) =>
      GoogleFonts.onest(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: size * -0.04,
        height: 0.98,
      );

  static TextStyle ui({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color? color,
  }) =>
      GoogleFonts.onest(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: size * -0.01,
      );

  static TextStyle label({
    double size = 11,
    Color? color,
    FontWeight weight = FontWeight.w600,
    double letterSpacing = 2.0,
  }) =>
      GoogleFonts.onest(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );
}
