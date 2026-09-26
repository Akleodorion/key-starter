import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/core/widgets/entry_card.dart';
import 'package:key_starter/features/note_recognition/presentation/pages/note_concept_page.dart';
import 'package:key_starter/features/note_recognition/presentation/pages/tempo_page.dart';
import 'package:key_starter/features/note_recognition/presentation/widgets/tempo_bpm_row.dart';

void main() {
  Future<void> pumpNoteConceptPage(WidgetTester tester) => tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const NoteConceptPage(),
      ),
    ),
  );

  group('NoteConceptPage', () {
    testWidgets('liste les exercices en commençant par "Notes simples"', (
      tester,
    ) async {
      //act
      await pumpNoteConceptPage(tester);

      //assert
      final exerciseTitles = tester
          .widgetList<EntryCard>(find.byType(EntryCard))
          .map((card) => card.entry.title)
          .toList();
      expect(exerciseTitles, [
        'Notes simples',
        'Flashcard',
        'Défilement',
        'Tempo',
      ]);
    });

    testWidgets('ouvre les réglages de Tempo quand on tape sur "Tempo"', (
      tester,
    ) async {
      //arrange
      await pumpNoteConceptPage(tester);
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
      expect(find.byType(TempoPage), findsOneWidget);
      expect(find.byType(TempoBpmRow), findsOneWidget);
      expect(find.text('Lancer'), findsOneWidget);
    });
  });
}
