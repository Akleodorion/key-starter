import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/widgets/midi_only_exercise_frame.dart';
import 'package:key_starter/features/chord_chart/domain/entities/bundled_chord_chart.dart';
import 'package:key_starter/features/chord_chart/presentation/widgets/chord_chart_play_body.dart';
import 'package:key_starter/features/chord_chart/presentation/widgets/chord_chart_play_top_bar.dart';

/// Jeu d'une grille, en paysage comme le jeu d'un morceau.
class ChordChartPlayPage extends StatefulWidget {
  final BundledChordChart bundledChordChart;

  const ChordChartPlayPage({super.key, required this.bundledChordChart});

  @override
  State<ChordChartPlayPage> createState() => _ChordChartPlayPageState();
}

class _ChordChartPlayPageState extends State<ChordChartPlayPage> {
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

    return MidiOnlyExerciseFrame(
      child: Scaffold(
        backgroundColor: colors.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ChordChartPlayTopBar(title: widget.bundledChordChart.title),
                const SizedBox(height: 8),
                Expanded(
                  child: ChordChartPlayBody(
                    bundledChordChart: widget.bundledChordChart,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
