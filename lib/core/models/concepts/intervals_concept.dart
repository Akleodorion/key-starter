import 'package:flutter/material.dart';
import 'package:key_starter/core/models/concept.dart';
import 'package:key_starter/core/theme/app_colors.dart';

class IntervalsConcept extends Concept {
  const IntervalsConcept()
    : super(
        title: 'Intervalles',
        description: 'Lire les intervalles',
        color: AppColors.intervalsFg,
        icon: Icons.straighten_rounded,
      );

  @override
  List<Object?> get props => [];
}
