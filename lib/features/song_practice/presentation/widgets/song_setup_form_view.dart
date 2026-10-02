import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/widgets/display_text.dart';
import 'package:key_starter/core/widgets/primary_button.dart';
import 'package:key_starter/core/widgets/ui_text.dart';
import 'package:key_starter/features/song_practice/domain/entities/bundled_song.dart';
import 'package:key_starter/features/song_practice/domain/entities/song.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_section.dart';
import 'package:key_starter/features/song_practice/presentation/pages/song_play_page.dart';
import 'package:key_starter/features/song_practice/presentation/providers/hand_selection.dart';
import 'package:key_starter/features/song_practice/presentation/providers/hand_selection_notifier.dart';
import 'package:key_starter/features/song_practice/presentation/providers/playable_events.dart';
import 'package:key_starter/features/song_practice/presentation/providers/section_selection_notifier.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_play_config.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/song_hand_selection_row.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/song_section_range_row.dart';

/// Réglages du morceau (mains, plage de mesures) qui défilent si la hauteur
/// manque, et le bouton Commencer toujours visible en bas.
class SongSetupFormView extends ConsumerWidget {
  final BundledSong bundledSong;
  final Song song;

  const SongSetupFormView({
    super.key,
    required this.bundledSong,
    required this.song,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorTheme.of(context);
    final hands = ref.watch(handSelectionProvider);
    final section =
        ref.watch(sectionSelectionProvider(bundledSong)) ??
        SongSection(
          firstMeasureNumber: 1,
          lastMeasureNumber: song.measureCount,
        );
    final hasNotesToPlay = playableEventIndices(
      song,
      hands,
      section,
    ).isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DisplayText(song.title),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border.all(color: colors.line),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SongHandSelectionRow(),
                      Divider(height: 1, thickness: 1, color: colors.line),
                      SongSectionRangeRow(
                        bundledSong: bundledSong,
                        section: section,
                        measureCount: song.measureCount,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!hasNotesToPlay) ...[
          const SizedBox(height: 12),
          Center(
            child: UiText(
              _noNotesMessage(hands),
              size: 13,
              color: AppColors.stateRed,
            ),
          ),
        ],
        const SizedBox(height: 12),
        PrimaryButton(
          label: 'Commencer',
          color: AppColors.songsFg,
          onPressed: hasNotesToPlay
              ? () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SongPlayPage(
                      config: SongPlayConfig(
                        song: song,
                        hands: hands,
                        section: section,
                      ),
                    ),
                  ),
                )
              : null,
        ),
      ],
    );
  }
}

String _noNotesMessage(HandSelection hands) => switch (hands) {
  HandSelection.rightOnly => 'Aucune note à la main droite dans ces mesures',
  HandSelection.leftOnly => 'Aucune note à la main gauche dans ces mesures',
  HandSelection.both => 'Aucune note dans ces mesures',
};
