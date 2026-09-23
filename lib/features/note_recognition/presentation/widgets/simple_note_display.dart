import 'package:flutter/material.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/core/widgets/feedback_animated_label.dart';

class SimpleNoteDisplay extends StatelessWidget {
  final int noteIndex;
  final NoteState noteState;
  final NoteLanguage language;

  const SimpleNoteDisplay({
    super.key,
    required this.noteIndex,
    required this.noteState,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final noteNames = language == NoteLanguage.fr ? noteNamesFr : noteNamesEn;
    return FeedbackAnimatedLabel(
      label: noteNames[noteIndex],
      noteState: noteState,
    );
  }
}
