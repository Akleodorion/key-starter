import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/theme/app_colors.dart';
import 'package:key_starter/core/widgets/primary_button.dart';
import 'package:key_starter/features/song_practice/domain/entities/song.dart';
import 'package:key_starter/features/song_practice/presentation/pages/song_play_page.dart';
import 'package:key_starter/features/song_practice/presentation/providers/hand_selection_notifier.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_play_config.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/song_hand_selection_row.dart';

class SongSetupFormView extends ConsumerWidget {
  final Song song;

  const SongSetupFormView({super.key, required this.song});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.line),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const SongHandSelectionRow(),
        ),
        const Spacer(),
        PrimaryButton(
          label: 'Commencer',
          color: AppColors.songsFg,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SongPlayPage(
                config: SongPlayConfig(
                  song: song,
                  hands: ref.read(handSelectionProvider),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
