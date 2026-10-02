import 'package:flutter/material.dart';
import 'package:key_starter/core/enums/note_language.dart';
import 'package:key_starter/core/models/two_staff_event.dart';
import 'package:key_starter/core/utils/two_staff_judgement.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/hand_note_names_info.dart';

/// Noms des notes attendues pour chaque main et, une fois jugé, les touches
/// détectées pour chacune.
class TwoStaffNoteNamesPanel extends StatelessWidget {
  final TwoStaffEvent event;
  final TwoStaffVerdict? verdict;
  final NoteLanguage language;

  const TwoStaffNoteNamesPanel({
    super.key,
    required this.event,
    required this.verdict,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: HandNoteNamesInfo(
            handLabel: 'Main droite',
            expectedSteps: event.trebleSteps,
            verdict: verdict?.treble,
            language: language,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: HandNoteNamesInfo(
            handLabel: 'Main gauche',
            expectedSteps: event.bassSteps,
            verdict: verdict?.bass,
            language: language,
          ),
        ),
      ],
    );
  }
}
