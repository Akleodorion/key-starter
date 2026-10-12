import 'package:flutter/material.dart';
import 'package:key_starter/core/models/concept.dart';
import 'package:key_starter/core/theme/app_colors.dart';

class ChordChartsConcept extends Concept {
  const ChordChartsConcept()
    : super(
        title: 'Grilles d\'accords',
        description: 'Jouer un morceau par ses accords',
        color: AppColors.chordChartsFg,
        tintColor: AppColors.chordChartsTint,
        darkTintColor: const Color(0xFF36260A),
        icon: Icons.grid_view_rounded,
      );

  @override
  List<Object?> get props => [];
}
