import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/core/widgets/entry_card.dart';
import 'package:key_starter/features/chord_recognition/presentation/pages/chord_concept_page.dart';

void main() {
  group('ChordConceptPage', () {
    testWidgets('liste les exercices en commençant par "Accords simples"', (
      tester,
    ) async {
      //act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const ChordConceptPage(),
          ),
        ),
      );

      //assert
      final exerciseTitles = tester
          .widgetList<EntryCard>(find.byType(EntryCard))
          .map((card) => card.entry.title)
          .toList();
      expect(exerciseTitles, ['Accords simples', 'Flashcard']);
    });
  });
}
