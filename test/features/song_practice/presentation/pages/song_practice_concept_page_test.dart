import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/input/input_source_kind.dart';
import 'package:key_starter/core/input/input_source_provider.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/core/widgets/entry_card.dart';
import 'package:key_starter/core/widgets/midi_only_entry_card.dart';
import 'package:key_starter/features/song_practice/presentation/pages/song_practice_concept_page.dart';
import 'package:key_starter/features/song_practice/presentation/pages/two_staff_flashcard_page.dart';

import '../../../../core/input/fake_input_source.dart';

void main() {
  group('SongPracticeConceptPage', () {
    testWidgets('ouvre le Test deux mains depuis sa carte', (tester) async {
      //arrange
      tester.view.devicePixelRatio = 2;
      tester.view.physicalSize = const Size(852, 393) * 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            inputSourceProvider.overrideWithValue(FakeInputSource()),
            activeInputSourceKindProvider.overrideWithValue(
              InputSourceKind.midi,
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const SongPracticeConceptPage(),
          ),
        ),
      );
      final exerciseTitles = tester
          .widgetList<EntryCard>(find.byType(EntryCard))
          .map((card) => card.entry.title)
          .toList();

      //act
      await tester.tap(
        find.descendant(
          of: find.ancestor(
            of: find.text('Test deux mains'),
            matching: find.byType(MidiOnlyEntryCard),
          ),
          matching: find.byType(GestureDetector),
        ),
      );
      await tester.pumpAndSettle();

      //assert
      expect(exerciseTitles, ['Test deux mains']);
      expect(find.byType(TwoStaffFlashcardPage), findsOneWidget);
    });
  });
}
