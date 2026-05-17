import 'package:flutter/material.dart';
import 'package:key_starter/core/models/concept.dart';
import 'package:key_starter/core/theme/app_colors.dart';

class ChordsConcept extends Concept {
  const ChordsConcept()
    : super(
        title: 'Accords',
        description: 'Lire les accords',
        color: AppColors.chordsFg,
        tintColor: AppColors.chordsTint,
        darkTintColor: const Color(0xFF3A1C10),
        icon: Icons.library_music_rounded,
      );

  @override
  List<Object?> get props => [];
}
