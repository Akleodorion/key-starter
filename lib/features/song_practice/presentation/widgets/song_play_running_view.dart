import 'package:flutter/material.dart';
import 'package:key_starter/core/widgets/concept_top_bar.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_play_config.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_play_state.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/song_measure_label.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/song_staff_card.dart';

class SongPlayRunningView extends StatelessWidget {
  final SongPlayConfig config;
  final SongPlayRunning running;

  const SongPlayRunningView({
    super.key,
    required this.config,
    required this.running,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConceptTopBar(title: config.song.title),
        const SizedBox(height: 4),
        SongMeasureLabel(
          measureNumber: running.currentEvent.measureNumber,
          measureCount: config.song.measureCount,
        ),
        const SizedBox(height: 8),
        Expanded(child: SongStaffCard(config: config)),
      ],
    );
  }
}
