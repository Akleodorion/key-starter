import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/input/input_source_provider.dart';
import 'package:key_starter/core/models/two_staff_event.dart';
import 'package:key_starter/core/utils/note_feedback_motion.dart';
import 'package:key_starter/features/song_practice/domain/entities/song.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_event.dart';
import 'package:key_starter/features/song_practice/presentation/providers/hand_selection.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_play_config.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_play_notifier.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_play_state.dart';

import '../../../../core/input/fake_input_source.dart';

const c3 = 48;
const g3 = 55;
const c4 = 60;
const d4 = 62;
const e4 = 64;

/// Mesure 1 : Mi4 + quinte Do3/Sol3, puis Ré4 ; mesure 2 : Sol3 seul, puis Do4.
const song = Song(
  title: 'Essai',
  measureCount: 2,
  events: [
    SongEvent(
      measureNumber: 1,
      onsetDivisions: 0,
      notes: TwoStaffEvent(trebleSteps: [2], bassSteps: [-7, -3]),
    ),
    SongEvent(
      measureNumber: 1,
      onsetDivisions: 2,
      notes: TwoStaffEvent(trebleSteps: [1], bassSteps: []),
    ),
    SongEvent(
      measureNumber: 2,
      onsetDivisions: 8,
      notes: TwoStaffEvent(trebleSteps: [], bassSteps: [-3]),
    ),
    SongEvent(
      measureNumber: 2,
      onsetDivisions: 12,
      notes: TwoStaffEvent(trebleSteps: [0], bassSteps: []),
    ),
  ],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeInputSource inputSource;
  late ProviderContainer container;
  late SongPlayConfig config;

  // Appelé dans fakeAsync : le notifier doit naître dans la zone simulée
  // pour que ses timers suivent l'horloge du test.
  void startSong({HandSelection hands = HandSelection.both}) {
    config = SongPlayConfig(song: song, hands: hands);
    inputSource = FakeInputSource();
    container = ProviderContainer(
      overrides: [inputSourceProvider.overrideWithValue(inputSource)],
    );
    addTearDown(container.dispose);
    container.listen(songPlayProvider(config), (_, _) {});
  }

  SongPlayState readState() => container.read(songPlayProvider(config));

  SongPlayRunning readRunning() => readState() as SongPlayRunning;

  group('SongPlayNotifier', () {
    group('build', () {
      test('démarre sur le premier événement, en mesure 1', () {
        fakeAsync((async) {
          //arrange
          //act
          startSong();
          final sut = readRunning();

          //assert
          expect(sut.currentEvent, song.events.first);
          expect(sut.noteState, NoteState.idle);
          expect(sut.errorCount, 0);
        });
      });
    });

    group('input', () {
      test(
        'colore juste puis passe à l\'événement suivant après le délai, touches encore tenues',
        () {
          fakeAsync((async) {
            //arrange
            startSong();

            //act
            [e4, c3, g3].forEach(inputSource.play);
            final stateAfterChord = readRunning();
            async.elapse(noteAdvanceDelay);
            final sut = readRunning();

            //assert
            expect(stateAfterChord.noteState, NoteState.correct);
            expect(sut.currentEvent, song.events[1]);
            expect(sut.noteState, NoteState.idle);
            expect(sut.verdict, isNull);
          });
        },
      );

      test('colore faux, passe quand même au suivant et compte l\'erreur', () {
        fakeAsync((async) {
          //arrange
          startSong();

          //act
          [d4, c3, g3].forEach(inputSource.play);
          final stateAfterChord = readRunning();
          async.elapse(noteAdvanceDelay);
          final sut = readRunning();

          //assert
          expect(stateAfterChord.noteState, NoteState.wrong);
          expect(stateAfterChord.verdict!.treble.isCorrect, isFalse);
          expect(sut.currentEvent, song.events[1]);
          expect(sut.errorCount, 1);
        });
      });

      test(
        'ignore la quinte tenue depuis l\'événement précédent pour juger le suivant',
        () {
          fakeAsync((async) {
            //arrange
            startSong();
            [e4, c3, g3].forEach(inputSource.play);
            inputSource.release(e4);
            async.elapse(noteAdvanceDelay);

            //act
            inputSource.play(d4);
            final sut = readRunning();

            //assert
            expect(sut.currentEvent, song.events[1]);
            expect(sut.noteState, NoteState.correct);
          });
        },
      );

      test(
        'compte pour l\'événement suivant une touche enfoncée pendant le retour visuel',
        () {
          fakeAsync((async) {
            //arrange
            startSong();
            [e4, c3, g3].forEach(inputSource.play);
            inputSource.release(e4);

            //act
            inputSource.play(d4);
            async.elapse(noteAdvanceDelay);
            final sut = readRunning();

            //assert
            expect(sut.currentEvent, song.events[1]);
            expect(sut.noteState, NoteState.correct);
          });
        },
      );
    });

    group('main droite seule', () {
      test('n\'attend que la clé de sol', () {
        fakeAsync((async) {
          //arrange
          startSong(hands: HandSelection.rightOnly);

          //act
          inputSource.play(e4);
          final sut = readRunning();

          //assert
          expect(sut.noteState, NoteState.correct);
        });
      });

      test('saute les événements où seule la main gauche joue', () {
        fakeAsync((async) {
          //arrange
          startSong(hands: HandSelection.rightOnly);
          inputSource.play(e4);
          async.elapse(noteAdvanceDelay);
          inputSource.play(d4);

          //act
          async.elapse(noteAdvanceDelay);
          final sut = readRunning();

          //assert
          expect(sut.currentEvent, song.events[3]);
        });
      });

      test('juge fausse une touche de la main gauche', () {
        fakeAsync((async) {
          //arrange
          startSong(hands: HandSelection.rightOnly);

          //act
          inputSource.play(c3);
          final sut = readRunning();

          //assert
          expect(sut.noteState, NoteState.wrong);
        });
      });
    });

    group('main gauche seule', () {
      test(
        'n\'attend que la clé de fa et saute les événements de main droite seule',
        () {
          fakeAsync((async) {
            //arrange
            startSong(hands: HandSelection.leftOnly);

            //act
            [c3, g3].forEach(inputSource.play);
            final stateAfterFifth = readRunning();
            [c3, g3].forEach(inputSource.release);
            async.elapse(noteAdvanceDelay);
            final sut = readRunning();

            //assert
            expect(stateAfterFifth.noteState, NoteState.correct);
            expect(sut.currentEvent, song.events[2]);
          });
        },
      );
    });

    group('fin du morceau', () {
      test('termine après le dernier événement avec le nombre d\'erreurs', () {
        fakeAsync((async) {
          //arrange
          startSong(hands: HandSelection.rightOnly);

          //act
          for (final midiNumber in [e4, e4, c4]) {
            inputSource.play(midiNumber);
            inputSource.release(midiNumber);
            async.elapse(noteAdvanceDelay);
          }
          final sut = readState();

          //assert
          expect(sut, const SongPlayFinished(errorCount: 1));
        });
      });

      test('recommence au premier événement, sans erreur, avec restart', () {
        fakeAsync((async) {
          //arrange
          startSong(hands: HandSelection.rightOnly);
          for (final midiNumber in [d4, d4, c4]) {
            inputSource.play(midiNumber);
            inputSource.release(midiNumber);
            async.elapse(noteAdvanceDelay);
          }

          //act
          container.read(songPlayProvider(config).notifier).restart();
          final sut = readRunning();

          //assert
          expect(sut.currentEvent, song.events.first);
          expect(sut.errorCount, 0);
          expect(sut.noteState, NoteState.idle);
        });
      });
    });
  });
}
