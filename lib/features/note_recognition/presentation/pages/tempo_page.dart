import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/widgets/concept_top_bar.dart';
import 'package:key_starter/core/widgets/display_text.dart';
import 'package:key_starter/core/widgets/primary_button.dart';
import 'package:key_starter/features/note_recognition/presentation/pages/tempo_exercise_page.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/tempo_bpm_notifier.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/tempo_exercise_config.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/tempo_settings_notifier.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/tempo_range_section.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/tempo_settings_card.dart';

class TempoPage extends ConsumerWidget {
  const TempoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorTheme.of(context);
    final config = TempoExerciseConfig(
      settings: ref.watch(tempoSettingsProvider),
      bpm: ref.watch(tempoBpmProvider),
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
                      DisplayText('Tempo'),
                      SizedBox(height: 32),
                      TempoSettingsCard(),
                      SizedBox(height: 24),
                      TempoRangeSection(),
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
                    builder: (_) => TempoExercisePage(config: config),
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
