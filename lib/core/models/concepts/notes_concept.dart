import 'package:flutter/material.dart';
import 'package:key_starter/core/models/concept.dart';
import 'package:key_starter/core/theme/app_colors.dart';

class NotesConcept extends Concept {
  const NotesConcept()
    : super(
        title: 'Notes',
        description: 'Apprends à reconnaître les notes sur la portée.',
        color: AppColors.notesFg,
        icon: Icons.music_note_rounded,
      );

  @override
  List<Object?> get props => [];
}
