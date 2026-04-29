import 'package:flutter/material.dart';

/// Design tokens — converted from the oklch values in the HTML prototype.
abstract final class AppColors {
  // ── Backgrounds ────────────────────────────────────────────────────────────
  /// oklch(0.985 0.005 95) — page background
  static const Color ivory = Color(0xFFFAF9F7);

  /// oklch(0.975 0.006 95) — card / input background
  static const Color paper = Color(0xFFF7F6F3);

  // ── Borders ────────────────────────────────────────────────────────────────
  /// oklch(0.92 0.006 95) — subtle dividers
  static const Color line = Color(0xFFE9E7E3);

  /// oklch(0.86 0.008 95) — visible borders
  static const Color lineStrong = Color(0xFFD9D6D1);

  // ── Text / ink ─────────────────────────────────────────────────────────────
  /// oklch(0.22 0.012 260) — primary text
  static const Color ink = Color(0xFF171B20);

  /// oklch(0.42 0.012 260) — secondary text
  static const Color inkSoft = Color(0xFF494D54);

  /// oklch(0.62 0.012 260) — placeholder / labels
  static const Color inkMute = Color(0xFF82868E);

  // ── Semantic ───────────────────────────────────────────────────────────────
  /// oklch(0.68 0.14 150) — correct / success
  static const Color ok = Color(0xFF3D9A6A);

  /// oklch(0.94 0.06 150) — success background tint
  static const Color okSoft = Color(0xFFD7F0E4);

  /// oklch(0.66 0.18 25) — wrong / error
  static const Color err = Color(0xFFCF5540);

  /// oklch(0.95 0.05 25) — error background tint
  static const Color errSoft = Color(0xFFF8ECE9);

  // ── Primary accent — warm amber ────────────────────────────────────────────
  /// oklch(0.68 0.17 45) — primary interactive color
  static const Color accent = Color(0xFFEB6F2F);

  /// oklch(0.55 0.15 45) — darker shade (gradients, pressed states)
  static const Color accentDeep = Color(0xFFB54E10);

  /// oklch(0.97 0.04 60) — lightest tint (feedback backgrounds)
  static const Color accentSoft = Color(0xFFFFEDDB);
}
