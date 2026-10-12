import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:key_starter/core/widgets/midi_only_entry_card.dart';
import 'package:key_starter/features/chord_chart/presentation/models/chord_chart_card_entry.dart';
import 'package:key_starter/features/chord_chart/presentation/providers/chord_chart_providers.dart';
import 'package:key_starter/features/chord_chart/presentation/widgets/chord_chart_load_error_view.dart';
import 'package:key_starter/features/chord_chart/presentation/widgets/chord_chart_loading_view.dart';

const _listErrorMessage = 'Impossible de lister les grilles.';

/// Une carte par grille livrée, dans l'ordre des titres.
class ChordChartListCards extends ConsumerWidget {
  const ChordChartListCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(chordChartListProvider)) {
      AsyncData(:final value) => value.fold(
        (_) => const ChordChartLoadErrorView(message: _listErrorMessage),
        (charts) => Column(
          children: [
            for (final bundledChordChart in charts) ...[
              MidiOnlyEntryCard(
                entry: ChordChartCardEntry(bundledChordChart),
                onTap: () {},
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
      AsyncError() => const ChordChartLoadErrorView(message: _listErrorMessage),
      _ => const ChordChartLoadingView(),
    };
  }
}
