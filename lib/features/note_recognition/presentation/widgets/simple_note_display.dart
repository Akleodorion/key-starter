import 'package:flutter/material.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/core/widgets/feedback_animated_label.dart';

class SimpleNoteDisplay extends StatelessWidget {
  final int pitchClass;
  final NoteState noteState;
  final NoteLanguage language;

  const SimpleNoteDisplay({
    super.key,
    required this.pitchClass,
    required this.noteState,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return FeedbackAnimatedLabel(
      label: pitchClassLabel(pitchClass, language),
      noteState: noteState,
    );
  }
}
