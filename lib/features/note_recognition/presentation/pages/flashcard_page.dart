import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/widgets/concept_top_bar.dart';
import 'package:key_starter/core/widgets/display_text.dart';
import 'package:key_starter/core/widgets/primary_button.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/flashcard_clef_row.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/flashcard_note_count_row.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/flashcard_range_section.dart';

class FlashcardPage extends StatelessWidget {
  const FlashcardPage({super.key});

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
              const ConceptTopBar(title: 'Notes'),
              const SizedBox(height: 32),
              const DisplayText('Flashcard'),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border.all(color: colors.line),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const FlashcardClefRow(),
                    Divider(height: 1, thickness: 1, color: colors.line),
                    const FlashcardNoteCountRow(),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const FlashcardRangeSection(),
              const Spacer(),
              PrimaryButton(
                label: 'Lancer',
                color: AppColors.notesFg,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
