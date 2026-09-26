import 'package:flutter/material.dart';
import 'package:key_starter/core/models/exercise.dart';
import 'package:key_starter/core/theme/app_colors.dart';

class ChordTempoExercise extends Exercise {
  const ChordTempoExercise()
    : super(
        icon: Icons.speed_rounded,
        title: 'Tempo',
        description: 'joue les accords en suivant le tempo',
        color: AppColors.chordsFg,
        tintColor: AppColors.chordsTint,
        darkTintColor: const Color(0xFF3A1C10),
      );

  @override
  List<Object?> get props => [];
}
