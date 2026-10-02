import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/input/input_source_kind.dart';
import 'package:key_starter/core/input/input_source_provider.dart';
import 'package:key_starter/core/models/two_staff_event.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/core/utils/note_feedback_motion.dart';
import 'package:key_starter/features/song_practice/domain/entities/song.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_event.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_measure.dart';
import 'package:key_starter/features/song_practice/presentation/pages/song_play_page.dart';
import 'package:key_starter/features/song_practice/presentation/providers/hand_selection.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_play_config.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/song_score_line.dart';

import '../../../../core/input/fake_input_source.dart';

const c4 = 60;

/// Six mesures (trois lignes), un Do 4 au premier temps de chaque mesure.
final config = SongPlayConfig(
  song: Song(
    title: 'Essai',
    measures: [
      for (var index = 0; index < 6; index++)
        SongMeasure(
          number: index + 1,
          startDivisions: index * 8,
          durationDivisions: 8,
        ),
    ],
    events: [
      for (var index = 0; index < 6; index++)
        SongEvent(
          measureNumber: index + 1,
          onsetDivisions: index * 8,
          notes: const TwoStaffEvent(trebleSteps: [0], bassSteps: []),
        ),
    ],
  ),
  hands: HandSelection.both,
);

void main() {
  late FakeInputSource inputSource;

  Future<void> pumpPlayPage(WidgetTester tester) async {
    tester.view.devicePixelRatio = 2;
    tester.view.physicalSize = const Size(667, 375) * 2;
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
          home: SongPlayPage(config: config),
        ),
      ),
    );
  }

  Future<void> playC4(WidgetTester tester) async {
    inputSource.play(c4);
    inputSource.release(c4);
    await tester.pump(noteAdvanceDelay);
    await tester.pump();
  }

  List<int> visibleFirstMeasureNumbers(WidgetTester tester) => tester
      .widgetList<SongScoreLine>(find.byType(SongScoreLine))
      .map((line) => line.line.firstMeasureNumber)
      .toList();

  group('SongPlayPage', () {
    testWidgets(
      'affiche deux lignes de partition, sans dépasser sur un petit téléphone en paysage',
      (tester) async {
        //act
        await pumpPlayPage(tester);

        //assert
        expect(tester.takeException(), isNull);
        expect(visibleFirstMeasureNumbers(tester), [1, 3]);
      },
    );

    testWidgets('fait défiler la partition au fil de l\'avancement', (
      tester,
    ) async {
      //arrange
      await pumpPlayPage(tester);

      //act
      await playC4(tester);
      await playC4(tester);
      await tester.pumpAndSettle();

      //assert
      expect(visibleFirstMeasureNumbers(tester), [3, 5]);
    });

    testWidgets('affiche la fin du morceau avec les erreurs, puis recommence', (
      tester,
    ) async {
      //arrange
      await pumpPlayPage(tester);

      //act
      for (var index = 0; index < 5; index++) {
        await playC4(tester);
      }
      inputSource.play(62);
      await tester.pump(noteAdvanceDelay);
      await tester.pump();
      final finishedTitleCount = find.text('Morceau terminé').evaluate().length;
      final errorLabelCount = find.text('1 erreur').evaluate().length;
      await tester.tap(find.text('Recommencer'));
      await tester.pumpAndSettle();

      //assert
      expect(finishedTitleCount, 1);
      expect(errorLabelCount, 1);
      expect(visibleFirstMeasureNumbers(tester), [1, 3]);
    });
  });
}
