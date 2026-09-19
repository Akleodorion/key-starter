import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/core/widgets/entry_card.dart';
import 'package:key_starter/features/note_recognition/presentation/pages/note_concept_page.dart';

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
    testWidgets('affiche une SnackBar au lieu de naviguer quand on tape sur '
        '"Mesure complète"', (tester) async {
      //arrange
      await pumpNoteConceptPage(tester);
      final mesureCompleteButton = find.descendant(
        of: find.ancestor(
          of: find.text('Mesure complète'),
          matching: find.byType(EntryCard),
        ),
        matching: find.byType(GestureDetector),
      );

      //act
      await tester.tap(mesureCompleteButton);
      await tester.pump();

      //assert
      expect(
        find.text("Cette fonctionnalité n'est pas encore disponible."),
        findsOneWidget,
      );
      expect(find.byType(NoteConceptPage), findsOneWidget);

      //cleanup : laisse le toast terminer son cycle (apparition + disparition)
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pump();
    });
  });
}
