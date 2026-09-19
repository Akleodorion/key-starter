import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/core/widgets/entry_card.dart';
import 'package:key_starter/presentation/pages/home_page.dart';

void main() {
  Future<void> pumpHomePage(WidgetTester tester) => tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(theme: AppTheme.light(), home: const HomePage()),
    ),
  );

  group('HomePage', () {
    testWidgets('affiche une SnackBar au lieu de naviguer quand on tape sur '
        '"Intervalles"', (tester) async {
      //arrange
      await pumpHomePage(tester);
      final intervalsButton = find.descendant(
        of: find.ancestor(
          of: find.text('Intervalles'),
          matching: find.byType(EntryCard),
        ),
        matching: find.byType(GestureDetector),
      );

      //act
      await tester.tap(intervalsButton);
      await tester.pump();

      //assert
      expect(
        find.text("Cette fonctionnalité n'est pas encore disponible."),
        findsOneWidget,
      );
      expect(find.byType(HomePage), findsOneWidget);

      //cleanup : laisse le toast terminer son cycle (apparition + disparition)
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pump();
    });
  });
}
