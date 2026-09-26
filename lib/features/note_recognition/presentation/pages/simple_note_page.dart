import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/widgets/concept_top_bar.dart';
import 'package:key_starter/core/widgets/display_text.dart';
import 'package:key_starter/core/widgets/primary_button.dart';
import 'package:key_starter/features/note_recognition/presentation/pages/simple_note_exercise_page.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/simple_note_black_keys_notifier.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/simple_note_exercise_config.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/simple_note_settings_notifier.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/simple_note_settings_card.dart';

class SimpleNotePage extends ConsumerWidget {
  const SimpleNotePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorTheme.of(context);
    final config = SimpleNoteExerciseConfig(
      noteCount: ref.watch(simpleNoteSettingsProvider).noteCount,
      includeBlackKeys: ref.watch(simpleNoteBlackKeysProvider),
    );

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ConceptTopBar(title: 'Notes'),
                      SizedBox(height: 32),
                      DisplayText('Notes simples'),
                      SizedBox(height: 32),
                      SimpleNoteSettingsCard(),
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
                    builder: (_) => SimpleNoteExercisePage(config: config),
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
