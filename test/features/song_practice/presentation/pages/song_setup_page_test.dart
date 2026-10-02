import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/errors/failures.dart';
import 'package:key_starter/core/input/input_source_kind.dart';
import 'package:key_starter/core/input/input_source_provider.dart';
import 'package:key_starter/core/models/two_staff_event.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/features/song_practice/domain/entities/bundled_song.dart';
import 'package:key_starter/features/song_practice/domain/entities/song.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_event.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_measure.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_section.dart';
import 'package:key_starter/features/song_practice/domain/repositories/song_repository.dart';
import 'package:key_starter/features/song_practice/domain/usecases/load_song_usecase.dart';
import 'package:key_starter/features/song_practice/presentation/pages/song_play_page.dart';
import 'package:key_starter/features/song_practice/presentation/pages/song_setup_page.dart';
import 'package:key_starter/features/song_practice/presentation/providers/hand_selection.dart';
import 'package:key_starter/features/song_practice/presentation/providers/hand_selection_notifier.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_providers.dart';

import '../../../../core/input/fake_input_source.dart';

/// Quatre mesures ; la main gauche ne joue qu'aux mesures 1 et 4.
const song = Song(
  title: 'Ode à la joie',
  measures: [
    SongMeasure(number: 1, startDivisions: 0, durationDivisions: 8),
    SongMeasure(number: 2, startDivisions: 8, durationDivisions: 8),
    SongMeasure(number: 3, startDivisions: 16, durationDivisions: 8),
    SongMeasure(number: 4, startDivisions: 24, durationDivisions: 8),
  ],
  events: [
    SongEvent(
      measureNumber: 1,
      onsetDivisions: 0,
      notes: TwoStaffEvent(trebleSteps: [2], bassSteps: [-7]),
    ),
    SongEvent(
      measureNumber: 2,
      onsetDivisions: 8,
      notes: TwoStaffEvent(trebleSteps: [1], bassSteps: []),
    ),
    SongEvent(
      measureNumber: 3,
      onsetDivisions: 16,
      notes: TwoStaffEvent(trebleSteps: [0], bassSteps: []),
    ),
    SongEvent(
      measureNumber: 4,
      onsetDivisions: 24,
      notes: TwoStaffEvent(trebleSteps: [2], bassSteps: [-7]),
    ),
  ],
);

/// [SongRepository] qui renvoie toujours [result].
class _StubSongRepository implements SongRepository {
  final Either<Failure, Song> result;

  _StubSongRepository(this.result);

  @override
  Future<Either<Failure, Song>> loadSong(BundledSong bundledSong) async =>
      result;
}

/// Galaxy Note 10 : environ 412 × 869 points.
const galaxyNote10Portrait = Size(412, 869);
const galaxyNote10Landscape = Size(869, 412);

void main() {
  late ProviderContainer container;

  ProviderContainer createContainer({
    Either<Failure, Song> result = const Right(song),
  }) {
    final newContainer = ProviderContainer(
      overrides: [
        inputSourceProvider.overrideWithValue(FakeInputSource()),
        activeInputSourceKindProvider.overrideWithValue(InputSourceKind.midi),
        loadSongUseCaseProvider.overrideWithValue(
          LoadSongUseCase(repository: _StubSongRepository(result)),
        ),
      ],
    );
    addTearDown(newContainer.dispose);
    return newContainer;
  }

  Future<void> pumpSetupPage(
    WidgetTester tester, {
    Size screenSize = galaxyNote10Portrait,
  }) async {
    tester.view.devicePixelRatio = 2;
    tester.view.physicalSize = screenSize * 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const SongSetupPage(bundledSong: odeToJoy),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> chooseMeasures(WidgetTester tester, int first, int last) async {
    tester.widget<RangeSlider>(find.byType(RangeSlider)).onChanged!(
      RangeValues(first.toDouble(), last.toDouble()),
    );
    await tester.pump();
  }

  bool isStartEnabled(WidgetTester tester) =>
      tester
          .widget<FilledButton>(
            find.ancestor(
              of: find.text('Commencer'),
              matching: find.byType(FilledButton),
            ),
          )
          .onPressed !=
      null;

  group('SongSetupPage', () {
    for (final (orientation, screenSize) in [
      ('portrait', galaxyNote10Portrait),
      ('paysage', galaxyNote10Landscape),
    ]) {
      testWidgets(
        'tient sans dépassement sur un Galaxy Note 10 en $orientation',
        (tester) async {
          //arrange
          container = createContainer();

          //act
          await pumpSetupPage(tester, screenSize: screenSize);

          //assert
          expect(tester.takeException(), isNull);
          expect(find.text('Commencer'), findsOneWidget);
        },
      );
    }

    testWidgets('propose les trois choix de main, deux mains par défaut', (
      tester,
    ) async {
      //arrange
      container = createContainer();

      //act
      await pumpSetupPage(tester);

      //assert
      expect(find.text('Ode à la joie'), findsWidgets);
      expect(find.text('Main droite'), findsOneWidget);
      expect(find.text('Deux mains'), findsOneWidget);
      expect(find.text('Main gauche'), findsOneWidget);
      expect(container.read(handSelectionProvider), HandSelection.both);
    });

    testWidgets(
      'propose le morceau entier par défaut et lance la plage de mesures choisie',
      (tester) async {
        //arrange
        container = createContainer();
        await pumpSetupPage(tester);
        final defaultLabelCount = find.text('Mesures 1 à 4').evaluate().length;
        await tester.tap(find.text('Main gauche'));
        await chooseMeasures(tester, 1, 4);
        await chooseMeasures(tester, 2, 4);

        //act
        await tester.tap(find.text('Commencer'));
        await tester.pumpAndSettle();

        //assert
        expect(defaultLabelCount, 1);
        final playPage = tester.widget<SongPlayPage>(find.byType(SongPlayPage));
        expect(playPage.config.hands, HandSelection.leftOnly);
        expect(playPage.config.song, song);
        expect(
          playPage.config.section,
          const SongSection(firstMeasureNumber: 2, lastMeasureNumber: 4),
        );
      },
    );

    testWidgets(
      'désactive Commencer quand la main choisie n\'a aucune note dans la plage',
      (tester) async {
        //arrange
        container = createContainer();
        await pumpSetupPage(tester);
        await tester.tap(find.text('Main gauche'));

        //act
        await chooseMeasures(tester, 2, 3);

        //assert
        expect(find.text('Mesures 2 à 3'), findsOneWidget);
        expect(
          find.text('Aucune note à la main gauche dans ces mesures'),
          findsOneWidget,
        );
        expect(isStartEnabled(tester), isFalse);
      },
    );

    testWidgets('retrouve la plage choisie en revenant sur la page', (
      tester,
    ) async {
      //arrange
      container = createContainer();
      await pumpSetupPage(tester);
      await chooseMeasures(tester, 2, 3);
      await tester.pumpWidget(const SizedBox());

      //act
      await pumpSetupPage(tester);

      //assert
      expect(find.text('Mesures 2 à 3'), findsOneWidget);
    });

    testWidgets('affiche la raison du refus d\'une partition', (tester) async {
      //arrange
      container = createContainer(
        result: const Left(
          UnsupportedSongFailure(
            'Les altérations (♯, ♭) ne sont pas encore prises en charge.',
          ),
        ),
      );

      //act
      await pumpSetupPage(tester);

      //assert
      expect(
        find.text(
          'Les altérations (♯, ♭) ne sont pas encore prises en charge.',
        ),
        findsOneWidget,
      );
      expect(find.text('Commencer'), findsNothing);
    });
  });
}
