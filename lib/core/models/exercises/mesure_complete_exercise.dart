import 'package:flutter/material.dart';
import 'package:key_starter/core/models/exercise.dart';
import 'package:key_starter/core/theme/app_colors.dart';

class MesureCompleteExercise extends Exercise {
  const MesureCompleteExercise()
      : super(
          icon: Icons.view_week_rounded,
          title: 'Mesure complète',
          description: 'lis une mesure, joue, on évalue',
          color: AppColors.notesFg,
          tintColor: AppColors.notesTint,
          darkTintColor: const Color(0xFF1C2550),
        );

  @override
  List<Object?> get props => [];
}
