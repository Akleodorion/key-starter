import 'package:flutter/material.dart';
import 'package:key_starter/core/models/concepts/chord_charts_concept.dart';
import 'package:key_starter/core/theme/app_color_theme.dart';
import 'package:key_starter/core/widgets/concept_header.dart';
import 'package:key_starter/core/widgets/concept_top_bar.dart';
import 'package:key_starter/features/chord_chart/presentation/widgets/chord_chart_list_cards.dart';

class ChordChartConceptPage extends StatelessWidget {
  const ChordChartConceptPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTheme.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ConceptTopBar(),
                const SizedBox(height: 32),
                const ConceptHeader(concept: ChordChartsConcept()),
                const SizedBox(height: 32),
                const ChordChartListCards(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
