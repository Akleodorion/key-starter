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
import 'package:key_starter/features/song_practice/domain/repositories/song_repository.dart';
import 'package:key_starter/features/song_practice/domain/usecases/load_song_usecase.dart';
import 'package:key_starter/features/song_practice/presentation/pages/song_play_page.dart';
import 'package:key_starter/features/song_practice/presentation/pages/song_setup_page.dart';
import 'package:key_starter/features/song_practice/presentation/providers/hand_selection.dart';
import 'package:key_starter/features/song_practice/presentation/providers/hand_selection_notifier.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_providers.dart';

import '../../../../core/input/fake_input_source.dart';

const song = Song(
  title: 'Ode à la joie',
  measureCount: 1,
  events: [
    SongEvent(
      measureNumber: 1,
      onsetDivisions: 0,
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

void main() {
  Future<void> pumpSetupPage(
    WidgetTester tester, {
    Either<Failure, Song> result = const Right(song),
  }) async {
    tester.view.devicePixelRatio = 2;
    tester.view.physicalSize = const Size(393, 852) * 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inputSourceProvider.overrideWithValue(FakeInputSource()),
          activeInputSourceKindProvider.overrideWithValue(InputSourceKind.midi),
          loadSongUseCaseProvider.overrideWithValue(
            LoadSongUseCase(repository: _StubSongRepository(result)),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const SongSetupPage(bundledSong: odeToJoy),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('SongSetupPage', () {
    testWidgets('propose les trois choix de main, deux mains par défaut', (
      tester,
    ) async {
      //act
      await pumpSetupPage(tester);

      //assert
      expect(find.text('Ode à la joie'), findsWidgets);
      expect(find.text('Main droite'), findsOneWidget);
      expect(find.text('Deux mains'), findsOneWidget);
      expect(find.text('Main gauche'), findsOneWidget);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(SongSetupPage)),
      );
      expect(container.read(handSelectionProvider), HandSelection.both);
    });

    testWidgets('lance le morceau avec la main choisie', (tester) async {
      //arrange
      await pumpSetupPage(tester);
      await tester.tap(find.text('Main gauche'));
      await tester.pump();

      //act
      await tester.tap(find.text('Commencer'));
      await tester.pumpAndSettle();

      //assert
      final playPage = tester.widget<SongPlayPage>(find.byType(SongPlayPage));
      expect(playPage.config.hands, HandSelection.leftOnly);
      expect(playPage.config.song, song);
    });

    testWidgets('affiche la raison du refus d\'une partition', (tester) async {
      //act
      await pumpSetupPage(
        tester,
        result: const Left(
          UnsupportedSongFailure(
            'Les altérations (♯, ♭) ne sont pas encore prises en charge.',
          ),
        ),
      );

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
