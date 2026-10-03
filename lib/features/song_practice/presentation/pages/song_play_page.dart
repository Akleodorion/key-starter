import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/widgets/midi_only_exercise_frame.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_play_config.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_tempo_play_notifier.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/song_free_play_view.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/song_play_top_bar.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/song_tempo_play_view.dart';

class SongPlayPage extends ConsumerStatefulWidget {
  final SongPlayConfig config;

  const SongPlayPage({super.key, required this.config});

  @override
  ConsumerState<SongPlayPage> createState() => _SongPlayPageState();
}

class _SongPlayPageState extends ConsumerState<SongPlayPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);
    final config = widget.config;
    final isTempo = config.bpm != null;

    return MidiOnlyExerciseFrame(
      onPause: isTempo
          ? () => ref.read(songTempoPlayProvider(config).notifier).pause()
          : null,
      onResume: isTempo
          ? () => ref.read(songTempoPlayProvider(config).notifier).resume()
          : null,
      child: Scaffold(
        backgroundColor: colors.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SongPlayTopBar(title: config.song.title, bpm: config.bpm),
                const SizedBox(height: 8),
                Expanded(
                  child: isTempo
                      ? SongTempoPlayView(config: config)
                      : SongFreePlayView(config: config),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
