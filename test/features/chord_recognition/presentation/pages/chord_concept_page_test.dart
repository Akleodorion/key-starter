import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/core/widgets/entry_card.dart';
import 'package:key_starter/features/chord_recognition/presentation/pages/chord_concept_page.dart';
import 'package:key_starter/features/chord_recognition/presentation/pages/chord_tempo_page.dart';
import 'package:key_starter/features/chord_recognition/presentation/widgets/chord_tempo_bpm_row.dart';

void main() {
  Future<void> pumpChordConceptPage(WidgetTester tester) => tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const ChordConceptPage(),
      ),
    ),
  );

  group('ChordConceptPage', () {
    testWidgets('liste les exercices en commençant par "Accords simples"', (
      tester,
    ) async {
      //act
      await pumpChordConceptPage(tester);

      //assert
      final exerciseTitles = tester
          .widgetList<EntryCard>(find.byType(EntryCard))
          .map((card) => card.entry.title)
          .toList();
      expect(exerciseTitles, ['Accords simples', 'Flashcard', 'Tempo']);
    });

    testWidgets('ouvre les réglages de Tempo quand on tape sur "Tempo"', (
      tester,
    ) async {
      //arrange
      await pumpChordConceptPage(tester);
      final tempoCard = find.descendant(
        of: find.ancestor(
          of: find.text('Tempo'),
          matching: find.byType(EntryCard),
        ),
        matching: find.byType(GestureDetector),
      );

      //act
      await tester.ensureVisible(tempoCard);
      await tester.tap(tempoCard);
      await tester.pumpAndSettle();

      //assert
      expect(find.byType(ChordTempoPage), findsOneWidget);
      expect(find.byType(ChordTempoBpmRow), findsOneWidget);
      expect(find.text('Lancer'), findsOneWidget);
    });
  });
}
