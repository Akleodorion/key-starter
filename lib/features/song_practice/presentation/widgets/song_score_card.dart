import 'package:flutter/material.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/utils/two_staff_judgement.dart';
import 'package:key_starter/core/widgets/tempo_count_in_label.dart';
import 'package:key_starter/features/song_practice/presentation/providers/hand_selection.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_play_config.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/song_score_lines.dart';

/// Carte qui contient la partition, les deux lignes se partageant toute la
/// hauteur disponible, avec le décompte par-dessus au tempo.
class SongScoreCard extends StatelessWidget {
  static const _verticalPadding = 4.0;

  final SongPlayConfig config;
  final Map<int, TwoStaffVerdict> judgedVerdicts;
  final int? currentEventIndex;
  final NoteState feedbackState;
  final ({int lineIndex, double fraction})? bar;
  final int? countInBeat;

  const SongScoreCard({
    super.key,
    required this.config,
    required this.judgedVerdicts,
    this.currentEventIndex,
    this.feedbackState = NoteState.idle,
    this.bar,
    this.countInBeat,
  });

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
        builder: (context, constraints) => Stack(
          alignment: Alignment.center,
          children: [
            SongScoreLines(
              song: config.song,
              judgedVerdicts: judgedVerdicts,
              currentEventIndex: currentEventIndex,
              bar: bar,
              feedbackState: feedbackState,
              trebleMuted: config.hands == HandSelection.leftOnly,
              bassMuted: config.hands == HandSelection.rightOnly,
              section: config.section,
              lineHeight: constraints.maxHeight / 2,
            ),
            TempoCountInLabel(beat: countInBeat, color: AppColors.songsFg),
          ],
        ),
      ),
    );
  }
}
