import 'package:flutter/material.dart';
import 'package:key_starter/core/models/exercise.dart';
import 'package:key_starter/core/theme/app_colors.dart';

class TempoExercise extends Exercise {
  const TempoExercise()
    : super(
        icon: Icons.speed_rounded,
        title: 'Tempo',
        description: 'joue les notes en suivant le tempo',
        color: AppColors.notesFg,
        tintColor: AppColors.notesTint,
        darkTintColor: const Color(0xFF1C2550),
      );

  @override
  List<Object?> get props => [];
}
