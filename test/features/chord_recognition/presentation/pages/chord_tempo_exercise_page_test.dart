import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/clef_mode.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/features/chord_recognition/presentation/pages/chord_tempo_exercise_page.dart';
import 'package:key_starter/features/note_recognition/presentation/providers/note_exercise_settings_state.dart';
import 'package:key_starter/features/chord_recognition/presentation/providers/chord_tempo_exercise_config.dart';
import 'package:key_starter/core/widgets/tempo_staff_line.dart';

void main() {
  const config = ChordTempoExerciseConfig(
    settings: NoteExerciseSettings(
      clef: ClefMode.treble,
      noteCount: 10,
      minNoteStep: 0,
      maxNoteStep: 10,
    ),
    bpm: 60,
  );

  Future<void> pumpExercisePageOnScreen(
    WidgetTester tester, {
    required Size logicalSize,
    EdgeInsets safeArea = EdgeInsets.zero,
  }) async {
    tester.view.devicePixelRatio = 2;
    tester.view.physicalSize = logicalSize * 2;
    tester.view.padding = FakeViewPadding(
      left: safeArea.left * 2,
      top: safeArea.top * 2,
      right: safeArea.right * 2,
      bottom: safeArea.bottom * 2,
    );
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const ChordTempoExercisePage(config: config),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('ChordTempoExercisePage', () {
    testWidgets('tient sans dépassement sur un petit téléphone en paysage', (
      tester,
    ) async {
      //arrange
      const iPhoneSeLandscape = Size(667, 375);

      //act
      await pumpExercisePageOnScreen(tester, logicalSize: iPhoneSeLandscape);

      //assert
      expect(tester.takeException(), isNull);
      expect(find.byType(TempoStaffLine), findsNWidgets(2));
      expect(find.text('Juste'), findsOneWidget);
    });

    testWidgets(
      'tient sans dépassement sur un iPhone à encoche en paysage, zone sûre comprise',
      (tester) async {
        //arrange
        const iPhoneLandscape = Size(852, 393);
        const notchAndHomeIndicator = EdgeInsets.fromLTRB(59, 0, 59, 21);

        //act
        await pumpExercisePageOnScreen(
          tester,
          logicalSize: iPhoneLandscape,
          safeArea: notchAndHomeIndicator,
        );

        //assert
        expect(tester.takeException(), isNull);
        expect(find.byType(TempoStaffLine), findsNWidgets(2));
      },
    );

    testWidgets('agrandit les portées sur une tablette en paysage', (
      tester,
    ) async {
      //arrange
      const iPadLandscape = Size(1180, 820);

      //act
      await pumpExercisePageOnScreen(tester, logicalSize: iPadLandscape);

      //assert
      expect(tester.takeException(), isNull);
      final lineHeight = tester
          .getSize(find.byType(TempoStaffLine).first)
          .height;
      expect(lineHeight, greaterThan(100));
    });
  });
}
