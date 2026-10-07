import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/theme/app_theme.dart';

import 'fake_note_range_section.dart';

void main() {
  late FakeNoteRangeSection sut;

  setUp(() {
    sut = FakeNoteRangeSection();
  });

  Future<void> pumpSection(WidgetTester tester, {double textScale = 1}) async {
    tester.view.devicePixelRatio = 2;
    tester.view.physicalSize = const Size(412, 869) * 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: sut,
            ),
          ),
        ),
      ),
    );
  }

  group('NoteRangeSection', () {
    testWidgets('affiche les deux bornes et la consigne par défaut', (
      tester,
    ) async {
      //act
      await pumpSection(tester);

      //assert
      expect(find.text('Sol 4'), findsOneWidget);
      expect(find.text('Sol 5'), findsOneWidget);
      expect(
        find.text('choisis la note la plus grave et la plus aiguë'),
        findsOneWidget,
      );
    });

    testWidgets(
      'passe le réglage « à » à la ligne plutôt que de déborder, police agrandie à 130 %',
      (tester) async {
        //act
        await pumpSection(tester, textScale: 1.3);

        //assert
        expect(tester.takeException(), isNull);
        final lowestTop = tester.getTopLeft(find.text('de')).dy;
        final highestTop = tester.getTopLeft(find.text('à')).dy;
        expect(highestTop, greaterThan(lowestTop));
      },
    );

    testWidgets('relie chaque bouton à son action', (tester) async {
      //arrange
      await pumpSection(tester);

      //act
      await tester.tap(find.byIcon(Icons.remove_rounded).first);
      await tester.tap(find.byIcon(Icons.add_rounded).first);
      await tester.tap(find.byIcon(Icons.remove_rounded).last);
      await tester.tap(find.byIcon(Icons.add_rounded).last);

      //assert
      expect(sut.calls, [
        'decrementMinNote',
        'incrementMinNote',
        'decrementMaxNote',
        'incrementMaxNote',
      ]);
    });
  });
}
