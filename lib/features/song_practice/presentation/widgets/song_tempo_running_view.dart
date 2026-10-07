import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/features/song_practice/presentation/layout/song_line_layout.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_play_config.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_tempo_play_notifier.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_tempo_play_state.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/song_score_card.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/song_score_lines.dart';

/// Section en cours au tempo : redessinée à chaque image pour faire avancer
/// la barre sur l'horloge du notifier.
class SongTempoRunningView extends ConsumerStatefulWidget {
  final SongPlayConfig config;
  final SongTempoPlayRunning running;

  const SongTempoRunningView({
    super.key,
    required this.config,
    required this.running,
  });

  @override
  ConsumerState<SongTempoRunningView> createState() =>
      _SongTempoRunningViewState();
}

class _SongTempoRunningViewState extends ConsumerState<SongTempoRunningView>
    with SingleTickerProviderStateMixin {
  late final Ticker _frameTicker = createTicker((_) => setState(() {}));

  @override
  void initState() {
    super.initState();
    _frameTicker.start();
  }

  @override
  void dispose() {
    _frameTicker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(songTempoPlayProvider(widget.config).notifier);
    final timeline = notifier.timeline;
    final elapsed = notifier.elapsed;

    return SongScoreCard(
      config: widget.config,
      judgedVerdicts: widget.running.judgedVerdicts,
      bar: songLinePositionAt(
        widget.config.song,
        timeline.barDivisionsAt(elapsed),
        measuresPerLine: songMeasuresPerLine,
      ),
      countInBeat: timeline.countInBeatAt(elapsed),
    );
  }
}
