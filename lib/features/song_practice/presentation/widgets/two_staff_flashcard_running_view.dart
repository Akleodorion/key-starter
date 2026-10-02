import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/providers/notation_language_provider.dart';
import 'package:key_starter/core/widgets/concept_top_bar.dart';
import 'package:key_starter/features/song_practice/presentation/providers/two_staff_flashcard_state.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/two_staff_flashcard_staff_card.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/two_staff_note_names_panel.dart';

class TwoStaffFlashcardRunningView extends ConsumerWidget {
  final TwoStaffFlashcardRunning running;

  const TwoStaffFlashcardRunningView({super.key, required this.running});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(notationLanguageProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ConceptTopBar(title: 'Test deux mains'),
        const SizedBox(height: 8),
        const Expanded(child: TwoStaffFlashcardStaffCard()),
        const SizedBox(height: 8),
        TwoStaffNoteNamesPanel(
          event: running.event,
          verdict: running.verdict,
          language: language,
        ),
      ],
    );
  }
}
