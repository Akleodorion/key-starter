import 'package:flutter/material.dart';
import 'package:key_starter/core/models/concepts/chords_concept.dart';
import 'package:key_starter/core/models/concepts/intervals_concept.dart';
import 'package:key_starter/core/models/concepts/notes_concept.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/widgets/display_text.dart';
import 'package:key_starter/core/widgets/entry_card.dart';
import 'package:key_starter/features/chord_recognition/presentation/pages/chord_concept_page.dart';
import 'package:key_starter/features/note_recognition/presentation/pages/note_concept_page.dart';
import 'package:key_starter/presentation/widgets/home_top_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
                const HomeTopBar(),
                const SizedBox(height: 32),
                DisplayText('Que veux tu travailler ?', color: colors.text),
                const SizedBox(height: 24),
                EntryCard(
                  entry: const NotesConcept(),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NoteConceptPage()),
                  ),
                ),
                const SizedBox(height: 12),
                EntryCard(
                  entry: const ChordsConcept(),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ChordConceptPage()),
                  ),
                ),
                const SizedBox(height: 12),
                const EntryCard(entry: IntervalsConcept()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
