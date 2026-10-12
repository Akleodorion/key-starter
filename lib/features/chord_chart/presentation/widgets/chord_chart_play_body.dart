import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/errors/failures.dart';
import 'package:key_starter/features/chord_chart/domain/entities/bundled_chord_chart.dart';
import 'package:key_starter/features/chord_chart/presentation/providers/chord_chart_providers.dart';
import 'package:key_starter/features/chord_chart/presentation/widgets/chord_chart_free_play_view.dart';
import 'package:key_starter/features/chord_chart/presentation/widgets/chord_chart_load_error_view.dart';
import 'package:key_starter/features/chord_chart/presentation/widgets/chord_chart_loading_view.dart';

const _unreadableChartMessage = 'Impossible de lire cette grille.';

/// Charge la grille, puis la fait jouer ; affiche la raison d'un refus.
class ChordChartPlayBody extends ConsumerWidget {
  final BundledChordChart bundledChordChart;

  const ChordChartPlayBody({super.key, required this.bundledChordChart});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(chordChartProvider(bundledChordChart))) {
      AsyncData(:final value) => value.fold(
        (failure) => ChordChartLoadErrorView(
          message: failure is UnsupportedChordChartFailure
              ? failure.reason
              : _unreadableChartMessage,
        ),
        (chart) => ChordChartFreePlayView(chart: chart),
      ),
      AsyncError() => const ChordChartLoadErrorView(
        message: _unreadableChartMessage,
      ),
      _ => const ChordChartLoadingView(),
    };
  }
}
