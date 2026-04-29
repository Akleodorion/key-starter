import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:key_starter/core/theme/app_colors.dart';

abstract final class AppTextStyles {
  // ── Display — Instrument Serif ─────────────────────────────────────────────
  // Grands titres, notes musicales affichées, chiffres clés.

  static TextStyle display({
    double size = 28,
    Color color = AppColors.ink,
    FontStyle style = FontStyle.normal,
  }) =>
      GoogleFonts.instrumentSerif(
        fontSize: size,
        fontStyle: style,
        color: color,
        letterSpacing: size * -0.02,
        height: 1.05,
      );

  // ── UI — DM Sans ───────────────────────────────────────────────────────────
  // Texte courant, boutons, labels de formulaire.

  static TextStyle ui({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.ink,
  }) =>
      GoogleFonts.dmSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: size * -0.01,
      );

  // ── Mono — DM Mono ─────────────────────────────────────────────────────────
  // Stats, compteurs, labels techniques, indicateurs MIDI.

  static TextStyle mono({
    double size = 12,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.inkMute,
    double letterSpacing = 0.06,
  }) =>
      GoogleFonts.dmMono(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: size * letterSpacing,
      );

  // ── Eyebrow — variante mono uppercase ─────────────────────────────────────
  // Petits titres de section en majuscules (ex: "PORTÉE", "DURÉE").

  static TextStyle eyebrow({Color color = AppColors.inkMute}) => mono(
        size: 11,
        color: color,
        letterSpacing: 0.10,
      );
}
