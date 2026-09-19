import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/presentation/widgets/notation_settings_row.dart';

void main() {
  Future<void> pumpNotationSettingsRow(WidgetTester tester) =>
      tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const Scaffold(body: NotationSettingsRow()),
          ),
        ),
      );

  group('NotationSettingsRow', () {
    testWidgets('affiche "Do Ré Mi" quand la notation française est active '
        'par défaut', (tester) async {
      //act
      await pumpNotationSettingsRow(tester);

      //assert
      expect(find.text('Do Ré Mi'), findsOneWidget);
      expect(find.text('C D E'), findsNothing);
    });

    testWidgets('affiche "C D E" après avoir basculé sur la notation '
        'anglaise', (tester) async {
      //arrange
      await pumpNotationSettingsRow(tester);

      //act
      await tester.tap(find.text('EN'));
      await tester.pumpAndSettle();

      //assert
      expect(find.text('C D E'), findsOneWidget);
      expect(find.text('Do Ré Mi'), findsNothing);
    });

    testWidgets('revient à "Do Ré Mi" en rebasculant sur le français', (
      tester,
    ) async {
      //arrange
      await pumpNotationSettingsRow(tester);
      await tester.tap(find.text('EN'));
      await tester.pumpAndSettle();

      //act
      await tester.tap(find.text('Fr'));
      await tester.pumpAndSettle();

      //assert
      expect(find.text('Do Ré Mi'), findsOneWidget);
      expect(find.text('C D E'), findsNothing);
    });
  });
}
