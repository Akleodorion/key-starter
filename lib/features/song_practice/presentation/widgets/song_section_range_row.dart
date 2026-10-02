import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/widgets/ui_text.dart';
import 'package:key_starter/features/song_practice/domain/entities/bundled_song.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_section.dart';
import 'package:key_starter/features/song_practice/presentation/providers/section_selection_notifier.dart';

/// Choix de la plage de mesures travaillée, de X à Y, sur toute la largeur.
class SongSectionRangeRow extends ConsumerWidget {
  final BundledSong bundledSong;
  final SongSection section;
  final int measureCount;

  const SongSectionRangeRow({
    super.key,
    required this.bundledSong,
    required this.section,
    required this.measureCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorTheme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UiText(
            'Mesures ${section.firstMeasureNumber} à ${section.lastMeasureNumber}',
            size: 15,
            weight: FontWeight.w600,
            color: colors.text,
          ),
          const SizedBox(height: 2),
          UiText('une plage continue', size: 12, color: colors.text2),
          if (measureCount > 1)
            RangeSlider(
              values: RangeValues(
                section.firstMeasureNumber.toDouble(),
                section.lastMeasureNumber.toDouble(),
              ),
              min: 1,
              max: measureCount.toDouble(),
              divisions: measureCount - 1,
              activeColor: AppColors.songsFg,
              onChanged: (values) => ref
                  .read(sectionSelectionProvider(bundledSong).notifier)
                  .select(
                    SongSection(
                      firstMeasureNumber: values.start.round(),
                      lastMeasureNumber: values.end.round(),
                    ),
                  ),
            ),
        ],
      ),
    );
  }
}
