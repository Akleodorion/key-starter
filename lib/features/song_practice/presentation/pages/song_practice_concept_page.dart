import 'package:flutter/material.dart';
import 'package:key_starter/core/models/concepts/songs_concept.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/widgets/concept_header.dart';
import 'package:key_starter/core/widgets/concept_top_bar.dart';
import 'package:key_starter/core/widgets/midi_only_entry_card.dart';
import 'package:key_starter/features/song_practice/domain/entities/bundled_song.dart';
import 'package:key_starter/features/song_practice/presentation/models/song_card_entry.dart';
import 'package:key_starter/features/song_practice/presentation/pages/song_setup_page.dart';

class SongPracticeConceptPage extends StatelessWidget {
  const SongPracticeConceptPage({super.key});

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
                const ConceptHeader(concept: SongsConcept()),
                const SizedBox(height: 32),
                MidiOnlyEntryCard(
                  entry: SongCardEntry(odeToJoy),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const SongSetupPage(bundledSong: odeToJoy),
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
