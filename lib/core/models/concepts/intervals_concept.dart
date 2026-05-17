import 'package:flutter/material.dart';
import 'package:key_starter/core/models/concept.dart';
import 'package:key_starter/core/theme/app_colors.dart';

class IntervalsConcept extends Concept {
  const IntervalsConcept()
    : super(
        title: 'Intervalles',
        description: 'Lire les intervalles',
        color: AppColors.intervalsFg,
        tintColor: AppColors.intervalsTint,
        darkTintColor: const Color(0xFF0E3025),
        icon: Icons.straighten_rounded,
      );

  @override
  List<Object?> get props => [];
}
