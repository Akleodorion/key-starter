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
import 'package:key_starter/features/song_practice/domain/entities/song_section.dart';
import 'package:key_starter/features/song_practice/presentation/pages/song_play_page.dart';
import 'package:key_starter/features/song_practice/presentation/providers/hand_selection.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_play_config.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_play_notifier.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_tempo_play_notifier.dart';
import 'package:key_starter/features/song_practice/presentation/widgets/song_score_line.dart';

import '../../../../core/input/fake_input_source.dart';

const c4 = 60;
const d4 = 62;

/// Six mesures de 4/4 (trois lignes), un Do 4 au premier temps de chaque
/// mesure ; à 60 BPM, une mesure dure 4 s.
final song = Song(
  title: 'Essai',
  divisionsPerQuarter: 2,
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
);

SongPlayConfig configFor(int firstMeasure, int lastMeasure, {int? bpm}) =>
    SongPlayConfig(
      song: song,
      hands: HandSelection.both,
      section: SongSection(
        firstMeasureNumber: firstMeasure,
        lastMeasureNumber: lastMeasure,
      ),
      bpm: bpm,
    );

const iPhoneSeLandscape = Size(667, 375);
const galaxyNote10Landscape = Size(869, 412);

void main() {
  late FakeInputSource inputSource;
  final startTime = DateTime(2026, 10, 3);
  var clockElapsed = Duration.zero;

  /// Ouvre la page de jeu par-dessus une page d'accueil, pour que la flèche
  /// retour ait où revenir.
  Future<void> pumpPlayPage(
    WidgetTester tester, {
    required SongPlayConfig config,
    Size screenSize = iPhoneSeLandscape,
  }) async {
    tester.view.devicePixelRatio = 2;
    tester.view.physicalSize = screenSize * 2;
    addTearDown(tester.view.reset);
    inputSource = FakeInputSource();
    clockElapsed = Duration.zero;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inputSourceProvider.overrideWithValue(inputSource),
          activeInputSourceKindProvider.overrideWithValue(InputSourceKind.midi),
          if (config.bpm != null)
            songTempoPlayProvider(config).overrideWith(
              () => SongTempoPlayNotifier(
                config,
                now: () => startTime.add(clockElapsed),
              ),
            ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => SongPlayPage(config: config)),
              ),
              child: const Text('Préparation'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Préparation'));
    if (config.bpm == null) {
      await tester.pumpAndSettle();
    } else {
      // La barre redessine la page à chaque image : pas de pumpAndSettle.
      // Horloge du morceau et timers avancent ensemble, transition comprise.
      await tester.pump();
      for (var step = 0; step < 4; step++) {
        clockElapsed += const Duration(milliseconds: 100);
        await tester.pump(const Duration(milliseconds: 100));
      }
    }
  }

  /// Fait avancer l'horloge du morceau au tempo et celle des timers.
  Future<void> advance(WidgetTester tester, Duration duration) async {
    const frame = Duration(milliseconds: 100);
    for (var step = Duration.zero; step < duration; step += frame) {
      clockElapsed += frame;
      await tester.pump(frame);
    }
  }

  Future<void> play(WidgetTester tester, int midiNumber) async {
    inputSource.play(midiNumber);
    inputSource.release(midiNumber);
    await tester.pump(noteAdvanceDelay);
    await tester.pump();
  }

  List<int> visibleFirstMeasureNumbers(WidgetTester tester) => tester
      .widgetList<SongScoreLine>(find.byType(SongScoreLine))
      .map((line) => line.line.firstMeasureNumber)
      .toList();

  group('SongPlayPage', () {
    for (final (device, screenSize) in [
      ('un iPhone SE', iPhoneSeLandscape),
      ('un Galaxy Note 10', galaxyNote10Landscape),
    ]) {
      testWidgets(
        'affiche deux lignes de partition, sans dépasser sur $device en paysage',
        (tester) async {
          //act
          await pumpPlayPage(
            tester,
            config: configFor(1, 6),
            screenSize: screenSize,
          );

          //assert
          expect(tester.takeException(), isNull);
          expect(visibleFirstMeasureNumbers(tester), [1, 3]);
        },
      );
    }

    testWidgets('fait défiler la partition au fil de l\'avancement', (
      tester,
    ) async {
      //arrange
      await pumpPlayPage(tester, config: configFor(1, 6));

      //act
      await play(tester, c4);
      await play(tester, c4);
      await tester.pumpAndSettle();

      //assert
      expect(visibleFirstMeasureNumbers(tester), [3, 5]);
    });

    testWidgets(
      'annonce la reprise d\'une section ratée puis revient à sa première ligne',
      (tester) async {
        //arrange
        await pumpPlayPage(tester, config: configFor(4, 6));

        //act
        await play(tester, d4);
        await play(tester, c4);
        await play(tester, c4);
        final retryMessageCount = find
            .text('1 erreur · on reprend')
            .evaluate()
            .length;
        await tester.pump(sectionRetryDelay);
        await tester.pumpAndSettle();

        //assert
        expect(retryMessageCount, 1);
        expect(visibleFirstMeasureNumbers(tester), [3, 5]);
      },
    );

    testWidgets(
      'reprend aussi une section réussie, après un message sans erreur',
      (tester) async {
        //arrange
        await pumpPlayPage(tester, config: configFor(5, 6));

        //act
        await play(tester, c4);
        await play(tester, c4);
        final successMessageCount = find
            .text('Sans erreur · on reprend')
            .evaluate()
            .length;
        final backArrowCountDuringMessage = find
            .byIcon(Icons.arrow_back_rounded)
            .evaluate()
            .length;
        await tester.pump(sectionRetryDelay);
        await tester.pumpAndSettle();

        //assert
        expect(successMessageCount, 1);
        expect(backArrowCountDuringMessage, 1);
        expect(visibleFirstMeasureNumbers(tester), [5]);
      },
    );

    testWidgets('n\'affiche pas de tempo en mode Libre', (tester) async {
      //act
      await pumpPlayPage(tester, config: configFor(1, 6));

      //assert
      expect(find.text('= 60'), findsNothing);
    });

    group('au tempo', () {
      testWidgets('arrête le tempo en revenant à la préparation', (
        tester,
      ) async {
        //arrange
        final config = configFor(1, 6, bpm: 60);
        await pumpPlayPage(tester, config: config);

        //act
        await tester.tap(find.byIcon(Icons.arrow_back_rounded));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump();

        //assert
        final container = ProviderScope.containerOf(
          tester.element(find.text('Préparation')),
        );
        expect(container.exists(songTempoPlayProvider(config)), isFalse);
      });

      testWidgets(
        'affiche le tempo, le décompte puis deux lignes sans dépasser',
        (tester) async {
          //arrange
          await pumpPlayPage(tester, config: configFor(1, 6, bpm: 60));
          final countInBeforeStart = find.text('4').evaluate().length;

          //act
          await advance(tester, const Duration(seconds: 1));

          //assert
          expect(tester.takeException(), isNull);
          expect(find.text('= 60'), findsOneWidget);
          expect(countInBeforeStart, 1);
          expect(find.text('3'), findsOneWidget);
          expect(visibleFirstMeasureNumbers(tester), [1, 3]);
        },
      );

      testWidgets('fait défiler la partition au passage de la barre', (
        tester,
      ) async {
        //arrange
        await pumpPlayPage(tester, config: configFor(1, 6, bpm: 60));

        //act
        await advance(tester, const Duration(milliseconds: 12500));

        //assert
        expect(visibleFirstMeasureNumbers(tester), [3, 5]);
      });

      testWidgets(
        'annonce la reprise au bout de la section puis refait le décompte',
        (tester) async {
          //arrange
          await pumpPlayPage(tester, config: configFor(5, 6, bpm: 60));

          //act
          await advance(tester, const Duration(seconds: 12));
          final retryMessageCount = find
              .text('2 erreurs · on reprend')
              .evaluate()
              .length;
          await advance(tester, sectionRetryDelay);

          //assert
          expect(retryMessageCount, 1);
          expect(find.text('4'), findsOneWidget);
          expect(visibleFirstMeasureNumbers(tester), [5]);
        },
      );
    });

    testWidgets('revient à la préparation avec la flèche retour', (
      tester,
    ) async {
      //arrange
      await pumpPlayPage(tester, config: configFor(1, 6));

      //act
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      //assert
      expect(find.byType(SongPlayPage), findsNothing);
      expect(find.text('Préparation'), findsOneWidget);
    });
  });
}
