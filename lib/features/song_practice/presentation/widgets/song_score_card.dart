import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/features/song_practice/presentation/providers/hand_selection.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_play_config.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_play_state.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/song_score_lines.dart';

/// Carte qui contient la partition, les deux lignes se partageant toute la
/// hauteur disponible.
class SongScoreCard extends StatelessWidget {
  static const _verticalPadding = 4.0;

  final SongPlayConfig config;
  final SongPlayRunning running;

  const SongScoreCard({super.key, required this.config, required this.running});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: _verticalPadding),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.line),
        borderRadius: BorderRadius.circular(20),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => SongScoreLines(
          song: config.song,
          judgedVerdicts: running.judgedVerdicts,
          currentEventIndex: running.currentEventIndex,
          feedbackState: running.noteState,
          trebleMuted: config.hands == HandSelection.leftOnly,
          bassMuted: config.hands == HandSelection.rightOnly,
          lineHeight: constraints.maxHeight / 2,
        ),
      ),
    );
  }
}
