import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/features/session/domain/entities/timing_offset.dart';
import 'package:key_starter/features/session/presentation/widgets/recap_stats_card.dart';

void main() {
  Future<void> pumpStatsCard(
    WidgetTester tester, {
    int? avgResponseMs,
    TimingOffset? timingOffset,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: RecapStatsCard(
          correctCount: 8,
          totalNotes: 10,
          avgResponseMs: avgResponseMs,
          timingOffset: timingOffset,
          bestStreak: 5,
        ),
      ),
    ),
  );

  group('RecapStatsCard', () {
    testWidgets('affiche le temps moyen sans écart au temps', (tester) async {
      //arrange
      //act
      await pumpStatsCard(tester, avgResponseMs: 1250);

      //assert
      expect(find.text('TEMPS MOYEN'), findsOneWidget);
      expect(find.text('1,3'), findsOneWidget);
    });

    testWidgets('affiche un retard moyen', (tester) async {
      //arrange
      //act
      await pumpStatsCard(
        tester,
        timingOffset: const TimingOffset(averageMs: 60),
      );

      //assert
      expect(find.text('RETARD MOYEN'), findsOneWidget);
      expect(find.text('60'), findsOneWidget);
      expect(find.text('ms'), findsOneWidget);
      expect(find.text('TEMPS MOYEN'), findsNothing);
    });

    testWidgets('affiche une avance moyenne sans signe', (tester) async {
      //arrange
      //act
      await pumpStatsCard(
        tester,
        timingOffset: const TimingOffset(averageMs: -40),
      );

      //assert
      expect(find.text('AVANCE MOYENNE'), findsOneWidget);
      expect(find.text('40'), findsOneWidget);
    });

    testWidgets('affiche un tiret sans note juste', (tester) async {
      //arrange
      //act
      await pumpStatsCard(
        tester,
        timingOffset: const TimingOffset(averageMs: null),
      );

      //assert
      expect(find.text('ÉCART MOYEN'), findsOneWidget);
      expect(find.text('—'), findsOneWidget);
    });
  });
}
