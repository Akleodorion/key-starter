import 'package:flutter/material.dart';
import 'package:key_starter/core/models/concept.dart';
import 'package:key_starter/core/theme/app_colors.dart';

class SongsConcept extends Concept {
  const SongsConcept()
    : super(
        title: 'Morceaux',
        description: 'Jouer à deux mains',
        color: AppColors.songsFg,
        tintColor: AppColors.songsTint,
        darkTintColor: const Color(0xFF2A1840),
        icon: Icons.queue_music_rounded,
      );

  @override
  List<Object?> get props => [];
}
