import 'package:flutter/material.dart';
import 'package:key_starter/core/models/concepts/chords_concept.dart';
import 'package:key_starter/core/models/concepts/intervals_concept.dart';
import 'package:key_starter/core/models/concepts/notes_concept.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';
import 'package:key_starter/core/widgets/concept_card.dart';
import 'package:key_starter/presentation/widgets/home_top_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeTopBar(),
              const SizedBox(height: 32),
              Text('Que veux tu travailler ?', style: AppTextStyles.display()),
              const SizedBox(height: 24),
              const ConceptCard(concept: NotesConcept()),
              const SizedBox(height: 12),
              const ConceptCard(concept: ChordsConcept()),
              const SizedBox(height: 12),
              const ConceptCard(concept: IntervalsConcept()),
            ],
          ),
        ),
      ),
    );
  }
}
