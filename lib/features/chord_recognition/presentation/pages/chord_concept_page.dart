import 'package:flutter/material.dart';
import 'package:key_starter/core/models/concepts/chords_concept.dart';
import 'package:key_starter/core/models/exercises/chord_flashcard_exercise.dart';
import 'package:key_starter/core/models/exercises/simple_chord_exercise.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/widgets/concept_header.dart';
import 'package:key_starter/core/widgets/concept_top_bar.dart';
import 'package:key_starter/core/widgets/entry_card.dart';
import 'package:key_starter/features/chord_recognition/presentation/pages/chord_flashcard_page.dart';
import 'package:key_starter/features/chord_recognition/presentation/pages/simple_chord_page.dart';

class ChordConceptPage extends StatelessWidget {
  const ChordConceptPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ConceptTopBar(),
                const SizedBox(height: 32),
                const ConceptHeader(concept: ChordsConcept()),
                const SizedBox(height: 32),
                EntryCard(
                  entry: const SimpleChordExercise(),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SimpleChordPage()),
                  ),
                ),
                const SizedBox(height: 12),
                EntryCard(
                  entry: const ChordFlashcardExercise(),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ChordFlashcardPage(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
