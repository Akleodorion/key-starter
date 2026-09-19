import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/widgets/concept_top_bar.dart';
import 'package:key_starter/core/widgets/display_text.dart';
import 'package:key_starter/core/widgets/primary_button.dart';
import 'package:key_starter/features/note_recognition/presentation/pages/defilement_exercise_page.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/defilement_settings_notifier.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/defilement_clef_row.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/defilement_note_count_row.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/defilement_range_section.dart';

class DefilementPage extends ConsumerWidget {
  const DefilementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorTheme.of(context);
    final settings = ref.watch(defilementSettingsProvider);

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ConceptTopBar(title: 'Notes'),
                      const SizedBox(height: 32),
                      const DisplayText('Défilement'),
                      const SizedBox(height: 32),
                      Container(
                        decoration: BoxDecoration(
                          color: colors.surface,
                          border: Border.all(color: colors.line),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const DefilementClefRow(),
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: colors.line,
                            ),
                            const DefilementNoteCountRow(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const DefilementRangeSection(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Lancer',
                color: AppColors.notesFg,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DefilementExercisePage(settings: settings),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
