import 'package:flutter/material.dart';
import 'package:key_starter/core/models/exercise.dart';
import 'package:key_starter/core/theme/app_colors.dart';

class DefilementExercise extends Exercise {
  const DefilementExercise()
    : super(
        icon: Icons.more_horiz_rounded,
        title: 'Défilement',
        description: 'la portée défile note après note',
        color: AppColors.notesFg,
        tintColor: AppColors.notesTint,
        darkTintColor: const Color(0xFF1C2550),
      );

  @override
  List<Object?> get props => [];
}
