import 'package:flutter/material.dart';
import 'package:key_starter/core/models/exercise.dart';
import 'package:key_starter/core/theme/app_colors.dart';

class FlashcardExercise extends Exercise {
  const FlashcardExercise()
    : super(
        icon: Icons.style_rounded,
        title: 'Flashcard',
        description: 'une note · feedback immédiat',
        color: AppColors.notesFg,
        tintColor: AppColors.notesTint,
        darkTintColor: const Color(0xFF1C2550),
      );

  @override
  List<Object?> get props => [];
}
