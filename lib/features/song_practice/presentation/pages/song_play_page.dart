import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/widgets/midi_only_exercise_frame.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_play_config.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_play_notifier.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_play_state.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/song_finished_view.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/song_play_running_view.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/song_retry_view.dart';

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
    final playState = ref.watch(songPlayProvider(widget.config));

    return MidiOnlyExerciseFrame(
      child: Scaffold(
        backgroundColor: colors.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: switch (playState) {
              SongPlayRunning() => SongPlayRunningView(
                config: widget.config,
                running: playState,
              ),
              SongPlayRetrying(:final errorCount) => SongRetryView(
                errorCount: errorCount,
              ),
              SongPlayFinished() => SongFinishedView(
                section: widget.config.section,
                measureCount: widget.config.song.measureCount,
                onRestart: () => ref
                    .read(songPlayProvider(widget.config).notifier)
                    .restart(),
                onQuit: () => Navigator.of(context).pop(),
              ),
            },
          ),
        ),
      ),
    );
  }
}
