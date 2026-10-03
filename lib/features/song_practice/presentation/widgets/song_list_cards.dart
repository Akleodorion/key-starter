import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/widgets/midi_only_entry_card.dart';
import 'package:key_starter/features/song_practice/presentation/models/song_card_entry.dart';
import 'package:key_starter/features/song_practice/presentation/pages/song_setup_page.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_providers.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/song_load_error_view.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/song_loading_view.dart';

/// Une carte par morceau livré, dans l'ordre des titres ; chacune ouvre la
/// préparation du morceau.
class SongListCards extends ConsumerWidget {
  const SongListCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(songListProvider)) {
      AsyncData(:final value) => value.fold(
        (_) => const SongLoadErrorView(
          message: 'Impossible de lister les morceaux.',
        ),
        (songs) => Column(
          children: [
            for (final bundledSong in songs) ...[
              MidiOnlyEntryCard(
                entry: SongCardEntry(bundledSong),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SongSetupPage(bundledSong: bundledSong),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
      AsyncError() => const SongLoadErrorView(
        message: 'Impossible de lister les morceaux.',
      ),
      _ => const SongLoadingView(),
    };
  }
}
