import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Backgrounds ────────────────────────────────────────────────────────────
  static const Color bg = Color(0xFFF4F3EE);
  static const Color bgInset = Color(0xFFECEBE4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFFBFAF6);

  // ── Borders ────────────────────────────────────────────────────────────────
  static const Color line = Color(0xFFE4E1D8);
  static const Color lineSoft = Color(0xFFEFECE4);

  // ── Text ───────────────────────────────────────────────────────────────────
  static const Color text = Color(0xFF0C0C0D);
  static const Color text2 = Color(0xFF6B6A70);
  static const Color text3 = Color(0xFFA3A2A8);
  static const Color text4 = Color(0xFFC4C3C8);

  // ── States ─────────────────────────────────────────────────────────────────
  static const Color stateGreen = Color(0xFF0E8A6A);
  static const Color stateRed = Color(0xFFC4502A);

  // ── Accents par section ────────────────────────────────────────────────────
  static const Color notesFg = Color(0xFF2845D9);
  static const Color notesTint = Color(0xFFE5EAFE);
  static const Color notesSoft = Color(0xFFF0F3FF);

  static const Color chordsFg = Color(0xFFC4502A);
  static const Color chordsTint = Color(0xFFFBE6DA);
  static const Color chordsSoft = Color(0xFFFDF2EC);

  static const Color intervalsFg = Color(0xFF0E8A6A);
  static const Color intervalsTint = Color(0xFFDCEFE6);
  static const Color intervalsSoft = Color(0xFFECF6F1);
}
