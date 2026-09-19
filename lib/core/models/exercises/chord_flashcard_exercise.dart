import 'package:flutter/material.dart';
import 'package:key_starter/core/models/exercise.dart';
import 'package:key_starter/core/theme/app_colors.dart';

class ChordFlashcardExercise extends Exercise {
  const ChordFlashcardExercise()
    : super(
        icon: Icons.style_rounded,
        title: 'Flashcard',
        description: 'un accord · feedback immédiat',
        color: AppColors.chordsFg,
        tintColor: AppColors.chordsTint,
        darkTintColor: const Color(0xFF3A1C10),
      );

  @override
  List<Object?> get props => [];
}
