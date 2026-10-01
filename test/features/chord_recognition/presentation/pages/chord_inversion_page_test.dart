import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/features/chord_recognition/presentation/pages/chord_inversion_page.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/chord_inversion_choice.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/chord_inversion_choice_notifier.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  Future<void> pumpPage(WidgetTester tester) => tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const ChordInversionPage(),
      ),
    ),
  );

  group('ChordInversionPage', () {
    testWidgets('propose le 1er renversement seul par défaut', (tester) async {
      //act
      await pumpPage(tester);

      //assert
      expect(
        container.read(chordInversionChoiceProvider),
        ChordInversionChoice.first,
      );
    });

    testWidgets('choisit les deux renversements d\'un tap', (tester) async {
      //arrange
      await pumpPage(tester);

      //act
      await tester.tap(find.text('Les deux'));
      await tester.pumpAndSettle();

      //assert
      expect(
        container.read(chordInversionChoiceProvider),
        ChordInversionChoice.both,
      );
    });
  });
}
