import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_play_config.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_play_notifier.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_play_state.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/song_play_running_view.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/song_retry_view.dart';

/// Jeu d'une section en tempo Libre : le repère attend chaque événement,
/// puis le message de reprise au bout de la section.
class SongFreePlayView extends ConsumerWidget {
  final SongPlayConfig config;

  const SongFreePlayView({super.key, required this.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(songPlayProvider(config))) {
      final SongPlayRunning running => SongPlayRunningView(
        config: config,
        running: running,
      ),
      SongPlayRetrying(:final errorCount) => SongRetryView(
        errorCount: errorCount,
      ),
    };
  }
}
