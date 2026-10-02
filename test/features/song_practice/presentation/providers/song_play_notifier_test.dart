import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/input/input_source_provider.dart';
import 'package:key_starter/core/models/two_staff_event.dart';
import 'package:key_starter/core/utils/note_feedback_motion.dart';
import 'package:key_starter/features/song_practice/domain/entities/song.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_event.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_measure.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_section.dart';
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
  measures: [
    SongMeasure(number: 1, startDivisions: 0, durationDivisions: 8),
    SongMeasure(number: 2, startDivisions: 8, durationDivisions: 8),
  ],
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
  void startSong({
    HandSelection hands = HandSelection.both,
    SongSection section = const SongSection(
      firstMeasureNumber: 1,
      lastMeasureNumber: 2,
    ),
  }) {
    config = SongPlayConfig(song: song, hands: hands, section: section);
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

    group('partition', () {
      test('expose l\'indice de l\'événement en cours dans le morceau', () {
        fakeAsync((async) {
          //arrange
          startSong();
          final initialIndex = readRunning().currentEventIndex;

          //act
          [e4, c3, g3].forEach(inputSource.play);
          async.elapse(noteAdvanceDelay);
          final sut = readRunning();

          //assert
          expect(initialIndex, 0);
          expect(sut.currentEventIndex, 1);
        });
      });

      test('garde le verdict de chaque événement déjà joué', () {
        fakeAsync((async) {
          //arrange
          startSong();
          [e4, c3, g3].forEach(inputSource.play);
          [e4, c3, g3].forEach(inputSource.release);
          async.elapse(noteAdvanceDelay);

          //act
          inputSource.play(c4);
          async.elapse(noteAdvanceDelay);
          final sut = readRunning();

          //assert
          expect(sut.judgedVerdicts.keys, [0, 1]);
          expect(sut.judgedVerdicts[0]!.isCorrect, isTrue);
          expect(sut.judgedVerdicts[1]!.isCorrect, isFalse);
        });
      });

      test(
        'saute dans l\'indice les événements de l\'autre main en mode une main',
        () {
          fakeAsync((async) {
            //arrange
            startSong(hands: HandSelection.rightOnly);
            inputSource.play(e4);
            inputSource.release(e4);
            async.elapse(noteAdvanceDelay);

            //act
            inputSource.play(d4);
            async.elapse(noteAdvanceDelay);
            final sut = readRunning();

            //assert
            expect(sut.currentEventIndex, 3);
          });
        },
      );
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

    group('section', () {
      test('commence au premier événement de la première mesure', () {
        fakeAsync((async) {
          //arrange
          //act
          startSong(
            section: const SongSection(
              firstMeasureNumber: 2,
              lastMeasureNumber: 2,
            ),
          );
          final sut = readRunning();

          //assert
          expect(sut.currentEventIndex, 2);
        });
      });

      test('s\'arrête après le dernier événement de la dernière mesure', () {
        fakeAsync((async) {
          //arrange
          startSong(
            section: const SongSection(
              firstMeasureNumber: 1,
              lastMeasureNumber: 1,
            ),
          );

          //act
          [e4, c3, g3].forEach(inputSource.play);
          [e4, c3, g3].forEach(inputSource.release);
          async.elapse(noteAdvanceDelay);
          inputSource.play(d4);
          async.elapse(noteAdvanceDelay);
          final sut = readState();

          //assert
          expect(sut, const SongPlayRetrying(errorCount: 0));
        });
      });

      test('ne retient que les événements de la main choisie', () {
        fakeAsync((async) {
          //arrange
          //act
          startSong(
            hands: HandSelection.rightOnly,
            section: const SongSection(
              firstMeasureNumber: 2,
              lastMeasureNumber: 2,
            ),
          );
          final sut = readRunning();

          //assert
          expect(sut.currentEventIndex, 3);
        });
      });
    });

    group('fin de section', () {
      test(
        'annonce une reprise avec le nombre d\'erreurs, puis recommence la section sans couleurs',
        () {
          fakeAsync((async) {
            //arrange
            startSong(hands: HandSelection.rightOnly);
            for (final midiNumber in [e4, e4, c4]) {
              inputSource.play(midiNumber);
              inputSource.release(midiNumber);
              async.elapse(noteAdvanceDelay);
            }
            final stateAtEnd = readState();

            //act
            async.elapse(sectionRetryDelay);
            final sut = readRunning();

            //assert
            expect(stateAtEnd, const SongPlayRetrying(errorCount: 1));
            expect(sut.currentEventIndex, 0);
            expect(sut.errorCount, 0);
            expect(sut.judgedVerdicts, isEmpty);
          });
        },
      );

      test('reprend aussi la section quand elle est jouée sans erreur', () {
        fakeAsync((async) {
          //arrange
          startSong(hands: HandSelection.rightOnly);
          for (final midiNumber in [e4, d4, c4]) {
            inputSource.play(midiNumber);
            inputSource.release(midiNumber);
            async.elapse(noteAdvanceDelay);
          }
          final stateAtEnd = readState();

          //act
          async.elapse(sectionRetryDelay);
          final sut = readRunning();

          //assert
          expect(stateAtEnd, const SongPlayRetrying(errorCount: 0));
          expect(sut.currentEventIndex, 0);
          expect(sut.judgedVerdicts, isEmpty);
        });
      });
    });
  });
}
