import 'package:flutter/material.dart';
import 'package:key_starter/core/models/card_entry.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/features/chord_chart/domain/entities/bundled_chord_chart.dart';

/// Carte d'une grille livrée avec l'app sur la page des grilles.
class ChordChartCardEntry extends CardEntry {
  ChordChartCardEntry(BundledChordChart bundledChordChart)
    : super(
        icon: Icons.grid_on_rounded,
        title: bundledChordChart.title,
        description: 'accord à droite · basse à gauche',
        color: AppColors.chordChartsFg,
        tintColor: AppColors.chordChartsTint,
        darkTintColor: const Color(0xFF36260A),
      );
}
