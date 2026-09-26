import 'package:flutter/material.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/core/widgets/feedback_animated_label.dart';

/// Fondamentales dont la triade diatonique de Do majeur s'écrit avec un « m »
/// (Ré, Mi, La, et Si par choix pédagogique au lieu du diminué).
const _minorSuffixRootIndexes = {1, 2, 5, 6};

String simpleChordLabel(int rootIndex, NoteLanguage language) {
  final noteNames = language == NoteLanguage.fr ? noteNamesFr : noteNamesEn;
  final suffix = _minorSuffixRootIndexes.contains(rootIndex) ? 'm' : '';
  return '|${noteNames[rootIndex]}$suffix';
}

class SimpleChordDisplay extends StatelessWidget {
  final int rootIndex;
  final NoteState noteState;
  final NoteLanguage language;

  const SimpleChordDisplay({
    super.key,
    required this.rootIndex,
    required this.noteState,
    required this.language,
  });

  @override
  Widget build(BuildContext context) => FeedbackAnimatedLabel(
    label: simpleChordLabel(rootIndex, language),
    noteState: noteState,
  );
}
