import 'package:flutter/material.dart';
import 'package:key_starter/core/models/exercise.dart';
import 'package:key_starter/core/theme/app_colors.dart';

class SimpleChordExercise extends Exercise {
  const SimpleChordExercise()
    : super(
        icon: Icons.piano_rounded,
        title: 'Accords simples',
        description: 'trouver les touches · sans partition',
        color: AppColors.chordsFg,
        tintColor: AppColors.chordsTint,
        darkTintColor: const Color(0xFF3A1C10),
      );

  @override
  List<Object?> get props => [];
}
