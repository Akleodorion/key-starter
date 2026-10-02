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
import 'package:key_starter/features/song_practice/presentation/pages/song_play_page.dart';
import 'package:key_starter/features/song_practice/presentation/providers/hand_selection.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_play_config.dart';

import '../../../../core/input/fake_input_source.dart';

const config = SongPlayConfig(
  song: Song(
    title: 'Essai',
    measureCount: 2,
    events: [
      SongEvent(
        measureNumber: 2,
        onsetDivisions: 8,
        notes: TwoStaffEvent(trebleSteps: [2], bassSteps: [-7]),
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
          home: const SongPlayPage(config: config),
        ),
      ),
    );
  }

  group('SongPlayPage', () {
    testWidgets(
      'indique la mesure en cours, sans dépasser sur un petit téléphone en paysage',
      (tester) async {
        //act
        await pumpPlayPage(tester);

        //assert
        expect(tester.takeException(), isNull);
        expect(find.text('Mesure 2 / 2'), findsOneWidget);
      },
    );

    testWidgets('affiche la fin du morceau avec les erreurs, puis recommence', (
      tester,
    ) async {
      //arrange
      await pumpPlayPage(tester);

      //act
      [62, 48].forEach(inputSource.play);
      await tester.pump(noteAdvanceDelay);
      await tester.pump();
      final finishedTitleCount = find.text('Morceau terminé').evaluate().length;
      final errorLabelCount = find.text('1 erreur').evaluate().length;
      await tester.tap(find.text('Recommencer'));
      await tester.pump();

      //assert
      expect(finishedTitleCount, 1);
      expect(errorLabelCount, 1);
      expect(find.text('Mesure 2 / 2'), findsOneWidget);
    });
  });
}
