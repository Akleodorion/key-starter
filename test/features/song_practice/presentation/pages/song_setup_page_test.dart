import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/errors/failures.dart';
import 'package:key_starter/core/input/input_source_kind.dart';
import 'package:key_starter/core/input/input_source_provider.dart';
import 'package:key_starter/core/models/two_staff_event.dart';
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
import 'package:key_starter/features/song_practice/presentation/providers/song_play_config.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_providers.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_tempo_notifier.dart';

import '../../../../core/input/fake_input_source.dart';
import '../../../../helpers/layout_test_helpers.dart';

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
  Future<Either<Failure, List<BundledSong>>> listSongs() async =>
      const Right([odeToJoy]);

  @override
  Future<Either<Failure, Song>> loadSong(BundledSong bundledSong) async =>
      result;
}

const odeToJoy = BundledSong(
  title: 'Ode à la joie',
  assetPath: 'assets/songs/ode_to_joy.mxl',
);

void main() {
  late ProviderContainer container;

  List<Override> songOverrides({
    Either<Failure, Song> result = const Right(song),
  }) => [
    inputSourceProvider.overrideWithValue(FakeInputSource()),
    activeInputSourceKindProvider.overrideWithValue(InputSourceKind.midi),
    loadSongUseCaseProvider.overrideWithValue(
      LoadSongUseCase(repository: _StubSongRepository(result)),
    ),
  ];

  ProviderContainer createContainer({
    Either<Failure, Song> result = const Right(song),
  }) {
    final newContainer = ProviderContainer(
      overrides: songOverrides(result: result),
    );
    addTearDown(newContainer.dispose);
    return newContainer;
  }

  Future<void> pumpSetupPage(WidgetTester tester) async {
    await pumpOnScreen(
      tester,
      const SongSetupPage(bundledSong: odeToJoy),
      container: container,
      textScale: 1,
    );
    await tester.pumpAndSettle();
  }

  Future<void> chooseMeasures(WidgetTester tester, int first, int last) async {
    tester.widget<RangeSlider>(find.byType(RangeSlider)).onChanged!(
      RangeValues(first.toDouble(), last.toDouble()),
    );
    await tester.pump();
  }

  /// Lance la page de jeu et renvoie sa configuration, puis la quitte pour
  /// arrêter l'horloge du tempo.
  Future<SongPlayConfig> startedConfig(WidgetTester tester) async {
    await tester.tap(find.text('Commencer'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    final config = tester
        .widget<SongPlayPage>(find.byType(SongPlayPage))
        .config;
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    return config;
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
    testNoOverflow(
      'affiche la préparation',
      () => const SongSetupPage(bundledSong: odeToJoy),
      overrides: songOverrides,
      arrange: (tester) => tester.pumpAndSettle(),
    );

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
        final startedPlayConfig = await startedConfig(tester);

        //assert
        expect(defaultLabelCount, 1);
        expect(startedPlayConfig.hands, HandSelection.leftOnly);
        expect(startedPlayConfig.song, song);
        expect(
          startedPlayConfig.section,
          const SongSection(firstMeasureNumber: 2, lastMeasureNumber: 4),
        );
      },
    );

    testWidgets('propose 60 noires par minute par défaut et lance ce tempo', (
      tester,
    ) async {
      //arrange
      container = createContainer();
      await pumpSetupPage(tester);

      //act
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();
      final startedPlayConfig = await startedConfig(tester);

      //assert
      expect(startedPlayConfig.bpm, 65);
    });

    testWidgets('passe en Libre sous 40 et lance le morceau sans tempo', (
      tester,
    ) async {
      //arrange
      container = createContainer();
      await pumpSetupPage(tester);
      expect(find.text('60'), findsOneWidget);

      //act
      for (var step = 0; step < 5; step++) {
        await tester.tap(find.byIcon(Icons.remove_rounded));
        await tester.pump();
      }
      final startedPlayConfig = await startedConfig(tester);

      //assert
      expect(startedPlayConfig.bpm, isNull);
    });

    testWidgets('affiche Libre quand le tempo est libre', (tester) async {
      //arrange
      container = createContainer();
      for (var step = 0; step < 5; step++) {
        container.read(songTempoProvider.notifier).decrement();
      }

      //act
      await pumpSetupPage(tester);

      //assert
      expect(find.text('Libre'), findsOneWidget);
    });

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
