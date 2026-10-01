import 'package:flutter/material.dart';
import 'package:key_starter/core/models/exercise.dart';
import 'package:key_starter/core/theme/app_colors.dart';

class ChordInversionExercise extends Exercise {
  const ChordInversionExercise()
    : super(
        icon: Icons.swap_vert_rounded,
        title: 'Renversements simples',
        description: 'trouver les touches · sans partition',
        color: AppColors.chordsFg,
        tintColor: AppColors.chordsTint,
        darkTintColor: const Color(0xFF3A1C10),
      );

  @override
  List<Object?> get props => [];
}
