import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/errors/failures.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/widgets/concept_top_bar.dart';
import 'package:key_starter/core/widgets/display_text.dart';
import 'package:key_starter/features/song_practice/domain/entities/bundled_song.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_providers.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/song_load_error_view.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/song_loading_view.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/song_setup_form_view.dart';

const _unreadableSongMessage = 'Impossible de lire la partition de ce morceau.';

class SongSetupPage extends ConsumerWidget {
  final BundledSong bundledSong;

  const SongSetupPage({super.key, required this.bundledSong});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorTheme.of(context);
    final songResult = ref.watch(songProvider(bundledSong));

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ConceptTopBar(title: 'Morceaux'),
              const SizedBox(height: 32),
              DisplayText(bundledSong.title),
              const SizedBox(height: 32),
              Expanded(
                child: switch (songResult) {
                  AsyncData(:final value) => value.fold(
                    (failure) => SongLoadErrorView(
                      message: failure is UnsupportedSongFailure
                          ? failure.reason
                          : _unreadableSongMessage,
                    ),
                    (song) => SongSetupFormView(song: song),
                  ),
                  AsyncError() => const SongLoadErrorView(
                    message: _unreadableSongMessage,
                  ),
                  _ => const SongLoadingView(),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
