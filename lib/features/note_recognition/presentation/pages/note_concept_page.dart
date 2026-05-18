import 'package:flutter/material.dart';
import 'package:key_starter/core/models/concepts/notes_concept.dart';
import 'package:key_starter/core/models/exercises/defilement_exercise.dart';
import 'package:key_starter/core/models/exercises/flashcard_exercise.dart';
import 'package:key_starter/core/models/exercises/mesure_complete_exercise.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/widgets/concept_header.dart';
import 'package:key_starter/core/widgets/concept_top_bar.dart';
import 'package:key_starter/core/widgets/entry_card.dart';
import 'package:key_starter/features/note_recognition/presentation/pages/flashcard_page.dart';

class NoteConceptPage extends StatelessWidget {
  const NoteConceptPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ConceptTopBar(),
              const SizedBox(height: 32),
              const ConceptHeader(concept: NotesConcept()),
              const SizedBox(height: 32),
              EntryCard(
                entry: const FlashcardExercise(),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FlashcardPage()),
                ),
              ),
              const SizedBox(height: 12),
              const EntryCard(entry: DefilementExercise()),
              const SizedBox(height: 12),
              const EntryCard(entry: MesureCompleteExercise()),
            ],
          ),
        ),
      ),
    );
  }
}
