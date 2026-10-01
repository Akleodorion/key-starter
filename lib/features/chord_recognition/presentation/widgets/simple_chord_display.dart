import 'package:flutter/material.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/core/widgets/feedback_animated_label.dart';
import 'package:key_starter/features/chord_recognition/domain/entities/chord_inversion.dart';
import 'package:key_starter/features/chord_recognition/domain/entities/chord_prompt.dart';

/// Fondamentales dont la triade diatonique de Do majeur s'écrit avec un « m »
/// (Ré, Mi, La, et Si par choix pédagogique au lieu du diminué).
const _minorSuffixRootIndexes = {1, 2, 5, 6};

/// Symbole d'accord, suivi du numéro de renversement entre parenthèses
/// (`|Do`, `|Rém(1)`, `|G(2)`).
String simpleChordLabel(ChordPrompt chord, NoteLanguage language) {
  final noteNames = language == NoteLanguage.fr ? noteNamesFr : noteNamesEn;
  final suffix = _minorSuffixRootIndexes.contains(chord.rootIndex) ? 'm' : '';
  final inversionMark = chord.inversion == ChordInversion.rootPosition
      ? ''
      : '(${chord.inversion.index})';
  return '|${noteNames[chord.rootIndex]}$suffix$inversionMark';
}

class SimpleChordDisplay extends StatelessWidget {
  final ChordPrompt chord;
  final NoteState noteState;
  final NoteLanguage language;

  const SimpleChordDisplay({
    super.key,
    required this.chord,
    required this.noteState,
    required this.language,
  });

  @override
  Widget build(BuildContext context) => FeedbackAnimatedLabel(
    label: simpleChordLabel(chord, language),
    noteState: noteState,
  );
}
