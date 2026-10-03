import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_play_config.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_tempo_play_notifier.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_tempo_play_state.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/song_retry_view.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/song_tempo_running_view.dart';

/// Jeu d'une section au tempo : la partition et sa barre, puis le message de
/// reprise au bout de la section.
class SongTempoPlayView extends ConsumerWidget {
  final SongPlayConfig config;

  const SongTempoPlayView({super.key, required this.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(songTempoPlayProvider(config))) {
      final SongTempoPlayRunning running => SongTempoRunningView(
        config: config,
        running: running,
      ),
      SongTempoPlayRetrying(:final errorCount) => SongRetryView(
        errorCount: errorCount,
      ),
    };
  }
}
