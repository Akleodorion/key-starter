import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/widgets/display_text.dart';
import 'package:key_starter/core/widgets/primary_button.dart';
import 'package:key_starter/core/widgets/ui_text.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_section.dart';

/// Écran d'une section jouée sans erreur : rappel de la plage, Recommencer
/// ou Quitter.
class SongFinishedView extends StatelessWidget {
  final SongSection section;
  final int measureCount;
  final VoidCallback onRestart;
  final VoidCallback onQuit;

  const SongFinishedView({
    super.key,
    required this.section,
    required this.measureCount,
    required this.onRestart,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);
    final isWholeSong =
        section.firstMeasureNumber == 1 &&
        section.lastMeasureNumber == measureCount;
    final sectionLabel = isWholeSong
        ? 'Morceau entier'
        : 'Mesures ${section.firstMeasureNumber} à ${section.lastMeasureNumber}';

    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const DisplayText('Section réussie'),
              const SizedBox(height: 8),
              UiText(sectionLabel, size: 16, color: colors.text2),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Recommencer',
                color: AppColors.songsFg,
                onPressed: onRestart,
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: onQuit, child: const Text('Quitter')),
            ],
          ),
        ),
      ),
    );
  }
}
