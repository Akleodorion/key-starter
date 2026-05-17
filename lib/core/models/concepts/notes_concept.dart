import 'package:flutter/material.dart';
import 'package:key_starter/core/models/concept.dart';
import 'package:key_starter/core/theme/app_colors.dart';

class NotesConcept extends Concept {
  const NotesConcept()
    : super(
        title: 'Notes',
        description: 'Lire les notes',
        color: AppColors.notesFg,
        tintColor: AppColors.notesTint,
        darkTintColor: const Color(0xFF1C2550),
        icon: Icons.music_note_rounded,
      );

  @override
  List<Object?> get props => [];
}
