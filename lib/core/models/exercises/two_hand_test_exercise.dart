import 'package:flutter/material.dart';
import 'package:key_starter/core/models/exercise.dart';
import 'package:key_starter/core/theme/app_colors.dart';

class TwoHandTestExercise extends Exercise {
  const TwoHandTestExercise()
    : super(
        icon: Icons.science_rounded,
        title: 'Test deux mains',
        description: 'une note ou un accord par main · détection',
        color: AppColors.songsFg,
        tintColor: AppColors.songsTint,
        darkTintColor: const Color(0xFF2A1840),
      );

  @override
  List<Object?> get props => [];
}
