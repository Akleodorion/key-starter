import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/input/input_source_kind.dart';
import 'package:key_starter/core/input/input_source_provider.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/core/utils/note_utils.dart';
import 'package:key_starter/core/widgets/grand_staff_widget.dart';
import 'package:key_starter/features/song_practice/presentation/pages/two_staff_flashcard_page.dart';
import 'package:key_starter/features/song_practice/presentation/providers/two_staff_flashcard_notifier.dart';
import 'package:key_starter/features/song_practice/presentation/providers/two_staff_flashcard_state.dart';

import '../../../../core/input/fake_input_source.dart';

void main() {
  late FakeInputSource inputSource;

  Future<void> pumpPageOnScreen(WidgetTester tester) async {
    const iPhoneSeLandscape = Size(667, 375);
    tester.view.devicePixelRatio = 2;
    tester.view.physicalSize = iPhoneSeLandscape * 2;
    addTearDown(tester.view.reset);
    inputSource = FakeInputSource();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inputSourceProvider.overrideWithValue(inputSource),
          activeInputSourceKindProvider.overrideWithValue(InputSourceKind.midi),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const TwoStaffFlashcardPage(),
        ),
      ),
    );
  }

  TwoStaffFlashcardRunning readState(WidgetTester tester) =>
      ProviderScope.containerOf(
            tester.element(find.byType(TwoStaffFlashcardPage)),
          ).read(twoStaffFlashcardProvider)
          as TwoStaffFlashcardRunning;

  group('TwoStaffFlashcardPage', () {
    testWidgets(
      'affiche la portée double et les notes attendues, sans dépasser sur un petit téléphone en paysage',
      (tester) async {
        //act
        await pumpPageOnScreen(tester);

        //assert
        expect(tester.takeException(), isNull);
        expect(
          find.byWidgetPredicate((widget) => widget is GrandStaffWidget),
          findsOneWidget,
        );
        expect(find.textContaining('Main droite : '), findsOneWidget);
        expect(find.textContaining('Main gauche : '), findsOneWidget);
      },
    );

    testWidgets('affiche les touches détectées par main une fois jugé', (
      tester,
    ) async {
      //arrange
      await pumpPageOnScreen(tester);
      final event = readState(tester).event;

      //act
      [
        ...event.trebleSteps,
        ...event.bassSteps,
      ].map(midiFromDiatonicStep).forEach(inputSource.play);
      await tester.pump();

      //assert
      expect(find.textContaining('Joué : '), findsNWidgets(2));
    });
  });
}
