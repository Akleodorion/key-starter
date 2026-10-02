import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/errors/failures.dart';
import 'package:key_starter/core/input/input_source_kind.dart';
import 'package:key_starter/core/input/input_source_provider.dart';
import 'package:key_starter/core/theme/app_theme.dart';
import 'package:key_starter/core/widgets/entry_card.dart';
import 'package:key_starter/core/widgets/midi_only_entry_card.dart';
import 'package:key_starter/features/song_practice/domain/entities/bundled_song.dart';
import 'package:key_starter/features/song_practice/domain/entities/song.dart';
import 'package:key_starter/features/song_practice/domain/repositories/song_repository.dart';
import 'package:key_starter/features/song_practice/domain/usecases/load_song_usecase.dart';
import 'package:key_starter/features/song_practice/presentation/pages/song_practice_concept_page.dart';
import 'package:key_starter/features/song_practice/presentation/pages/song_setup_page.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_providers.dart';

import '../../../../core/input/fake_input_source.dart';

/// [SongRepository] qui renvoie un morceau vide.
class _EmptySongRepository implements SongRepository {
  @override
  Future<Either<Failure, Song>> loadSong(BundledSong bundledSong) async =>
      Right(Song(title: bundledSong.title, measureCount: 0, events: const []));
}

void main() {
  group('SongPracticeConceptPage', () {
    testWidgets('ouvre la préparation de l\'Ode à la joie depuis sa carte', (
      tester,
    ) async {
      //arrange
      tester.view.devicePixelRatio = 2;
      tester.view.physicalSize = const Size(393, 852) * 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            inputSourceProvider.overrideWithValue(FakeInputSource()),
            activeInputSourceKindProvider.overrideWithValue(
              InputSourceKind.midi,
            ),
            loadSongUseCaseProvider.overrideWithValue(
              LoadSongUseCase(repository: _EmptySongRepository()),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const SongPracticeConceptPage(),
          ),
        ),
      );
      final songTitles = tester
          .widgetList<EntryCard>(find.byType(EntryCard))
          .map((card) => card.entry.title)
          .toList();

      //act
      await tester.tap(
        find.descendant(
          of: find.ancestor(
            of: find.text('Ode à la joie'),
            matching: find.byType(MidiOnlyEntryCard),
          ),
          matching: find.byType(GestureDetector),
        ),
      );
      await tester.pumpAndSettle();

      //assert
      expect(songTitles, ['Ode à la joie']);
      final setupPage = tester.widget<SongSetupPage>(
        find.byType(SongSetupPage),
      );
      expect(setupPage.bundledSong, odeToJoy);
    });
  });
}
