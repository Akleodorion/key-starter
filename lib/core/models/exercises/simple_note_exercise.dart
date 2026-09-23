import 'package:flutter/material.dart';
import 'package:key_starter/core/models/exercise.dart';
import 'package:key_starter/core/theme/app_colors.dart';

class SimpleNoteExercise extends Exercise {
  const SimpleNoteExercise()
    : super(
        icon: Icons.piano_rounded,
        title: 'Notes simples',
        description: 'trouver la touche · sans partition',
        color: AppColors.notesFg,
        tintColor: AppColors.notesTint,
        darkTintColor: const Color(0xFF1C2550),
      );

  @override
  List<Object?> get props => [];
}
