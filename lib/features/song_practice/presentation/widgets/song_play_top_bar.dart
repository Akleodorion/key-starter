import 'package:flutter/material.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_text_styles.dart';
import 'package:key_starter/core/widgets/input_source_pill.dart';
import 'package:key_starter/core/widgets/primary_icon_button.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/song_tempo_mark.dart';

/// Barre du haut de la page de jeu : retour, titre du morceau suivi du tempo
/// quand il y en a un, source d'entrée.
class SongPlayTopBar extends StatelessWidget {
  final String title;
  final int? bpm;

  const SongPlayTopBar({super.key, required this.title, required this.bpm});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);
    final currentBpm = bpm;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        PrimaryIconButton(
          icon: Icons.arrow_back_rounded,
          onTap: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.ui(size: 14, color: colors.text2),
                ),
              ),
              if (currentBpm != null) ...[
                const SizedBox(width: 12),
                SongTempoMark(bpm: currentBpm),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        const InputSourcePill(),
      ],
    );
  }
}
