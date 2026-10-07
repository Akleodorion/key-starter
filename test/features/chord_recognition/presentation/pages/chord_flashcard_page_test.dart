import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/features/chord_recognition/presentation/pages/chord_flashcard_page.dart';

/// Galaxy Note 10 : environ 412 × 869 points.
const galaxyNote10Portrait = Size(412, 869);
const galaxyNote10Landscape = Size(869, 412);

void main() {
  Future<void> pumpChordFlashcardPage(
    WidgetTester tester, {
    required Size screenSize,
    required double textScale,
  }) async {
    tester.view.devicePixelRatio = 2;
    tester.view.physicalSize = screenSize * 2;
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
          home: const ChordFlashcardPage(),
        ),
      ),
    );
  }

  group('ChordFlashcardPage', () {
    for (final (orientation, screenSize) in [
      ('portrait', galaxyNote10Portrait),
      ('paysage', galaxyNote10Landscape),
    ]) {
      testWidgets(
        'tient sans dépassement sur un Galaxy Note 10 en $orientation, police agrandie à 130 %',
        (tester) async {
          //act
          await pumpChordFlashcardPage(
            tester,
            screenSize: screenSize,
            textScale: 1.3,
          );

          //assert
          expect(tester.takeException(), isNull);
          expect(find.text('Lancer'), findsOneWidget);
        },
      );
    }
  });
}
