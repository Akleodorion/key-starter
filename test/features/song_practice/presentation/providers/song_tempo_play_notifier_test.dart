import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/input/input_source_provider.dart';
import 'package:key_starter/core/models/two_staff_event.dart';
import 'package:key_starter/features/song_practice/domain/entities/song.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_event.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_measure.dart';
import 'package:key_starter/features/song_practice/domain/entities/song_section.dart';
import 'package:key_starter/features/song_practice/presentation/providers/hand_selection.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_play_config.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_play_notifier.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_tempo_play_notifier.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_tempo_play_state.dart';

import '../../../../core/input/fake_input_source.dart';

const c3 = 48;
const g3 = 55;
const c4 = 60;
const d4 = 62;
const e4 = 64;
const f4 = 65;

/// 4/4, 2 divisions par noire. Mesure 1 : Mi4 + quinte Do3/Sol3, Ré4, puis
/// Do4 une croche après ; mesure 2 : Sol3 seul, puis Do4.
///
/// À 60 BPM : décompte de 4 s, événements à 4 s, 5 s, 5,5 s, 8 s et 10 s,
/// fenêtres de ±250 ms, fin de la section entière à 12 s.
const song = Song(
  title: 'Essai',
  divisionsPerQuarter: 2,
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
      measureNumber: 1,
      onsetDivisions: 3,
      notes: TwoStaffEvent(trebleSteps: [0], bassSteps: []),
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

const wholeSong = SongSection(firstMeasureNumber: 1, lastMeasureNumber: 2);

Duration ms(int milliseconds) => Duration(milliseconds: milliseconds);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final startTime = DateTime(2026, 10, 3);
  late FakeInputSource inputSource;
  late ProviderContainer container;
  late SongPlayConfig config;

  /// Lance le morceau au tempo sur une horloge simulée et passe l'horloge au
  /// corps du test, qui la fait avancer avec [FakeAsync.elapse].
  void runSong(
    void Function(FakeAsync async) body, {
    HandSelection hands = HandSelection.both,
    SongSection section = wholeSong,
  }) {
    fakeAsync((async) {
      config = SongPlayConfig(
        song: song,
        hands: hands,
        section: section,
        bpm: 60,
      );
      inputSource = FakeInputSource();
      container = ProviderContainer(
        overrides: [
          inputSourceProvider.overrideWithValue(inputSource),
          songTempoPlayProvider(config).overrideWith(
            () => SongTempoPlayNotifier(
              config,
              now: () => startTime.add(async.elapsed),
            ),
          ),
        ],
      );
      container.listen(songTempoPlayProvider(config), (_, _) {});
      body(async);
      container.dispose();
      async.flushTimers();
    });
  }

  SongTempoPlayState readState() =>
      container.read(songTempoPlayProvider(config));

  SongTempoPlayRunning readRunning() => readState() as SongTempoPlayRunning;

  SongTempoPlayNotifier readNotifier() =>
      container.read(songTempoPlayProvider(config).notifier);

  void elapseUntil(FakeAsync async, Duration target) =>
      async.elapse(target - async.elapsed);

  /// Joue [midiNumbers] à l'instant [at] depuis le début du décompte.
  void playAt(FakeAsync async, Duration at, List<int> midiNumbers) {
    elapseUntil(async, at);
    for (final midiNumber in midiNumbers) {
      inputSource.play(midiNumber, attackTime: startTime.add(async.elapsed));
    }
  }

  group('SongTempoPlayNotifier', () {
    group('build', () {
      test('démarre sur le décompte, sans verdict ni erreur', () {
        runSong((async) {
          //arrange
          //act
          final sut = readRunning();

          //assert
          expect(sut.judgedVerdicts, isEmpty);
          expect(sut.errorCount, 0);
          expect(
            readNotifier().timeline.isCountIn(readNotifier().elapsed),
            isTrue,
          );
        });
      });

      test('ignore les touches jouées pendant le décompte', () {
        runSong((async) {
          //arrange
          //act
          playAt(async, ms(1000), [e4, c3, g3]);
          elapseUntil(async, ms(3700));

          //assert
          expect(readRunning().judgedVerdicts, isEmpty);
          expect(readRunning().errorCount, 0);
        });
      });
    });

    group('fenêtre d\'un événement', () {
      test('passe juste dès que toutes les notes attendues sont jouées', () {
        runSong((async) {
          //arrange
          //act
          playAt(async, ms(4000), [e4, c3, g3]);

          //assert
          expect(readRunning().judgedVerdicts[0]!.isCorrect, isTrue);
          expect(readRunning().errorCount, 0);
        });
      });

      test('regroupe les touches jouées dans toute la fenêtre', () {
        runSong((async) {
          //arrange
          playAt(async, ms(3800), [c3]);
          playAt(async, ms(4100), [e4]);

          //act
          playAt(async, ms(4200), [g3]);

          //assert
          expect(readRunning().judgedVerdicts[0]!.isCorrect, isTrue);
        });
      });

      test(
        'juge faux à la fermeture de la fenêtre quand il manque une note',
        () {
          runSong((async) {
            //arrange
            playAt(async, ms(4000), [e4, c3]);
            elapseUntil(async, ms(4200));
            final verdictsBeforeClose = readRunning().judgedVerdicts;

            //act
            elapseUntil(async, ms(4300));
            final sut = readRunning();

            //assert
            expect(verdictsBeforeClose, isEmpty);
            expect(sut.judgedVerdicts[0]!.isCorrect, isFalse);
            expect(sut.judgedVerdicts[0]!.treble.isCorrect, isTrue);
            expect(sut.judgedVerdicts[0]!.bass.isCorrect, isFalse);
            expect(sut.errorCount, 1);
          });
        },
      );

      test('juge faux à la fermeture une note en trop jouée avant', () {
        runSong((async) {
          //arrange
          playAt(async, ms(3900), [f4]);
          playAt(async, ms(4000), [e4, c3, g3]);

          //act
          elapseUntil(async, ms(4300));

          //assert
          expect(readRunning().judgedVerdicts[0]!.isCorrect, isFalse);
          expect(readRunning().errorCount, 1);
        });
      });

      test('ignore une touche de plus une fois l\'événement juste', () {
        runSong((async) {
          //arrange
          playAt(async, ms(4000), [e4, c3, g3]);

          //act
          playAt(async, ms(4100), [f4]);
          elapseUntil(async, ms(4300));

          //assert
          expect(readRunning().judgedVerdicts[0]!.isCorrect, isTrue);
          expect(readRunning().errorCount, 0);
        });
      });

      test('compte faux un événement que personne ne joue', () {
        runSong((async) {
          //arrange
          //act
          elapseUntil(async, ms(4300));

          //assert
          expect(readRunning().judgedVerdicts[0]!.isCorrect, isFalse);
          expect(readRunning().errorCount, 1);
        });
      });

      test('attribue une touche à la croche dont la fenêtre la contient', () {
        runSong((async) {
          //arrange
          playAt(async, ms(4000), [e4, c3, g3]);

          //act
          playAt(async, ms(5200), [d4]);
          playAt(async, ms(5300), [c4]);

          //assert
          expect(readRunning().judgedVerdicts[1]!.isCorrect, isTrue);
          expect(readRunning().judgedVerdicts[2]!.isCorrect, isTrue);
        });
      });
    });

    group('touche hors fenêtre', () {
      test('compte faux le prochain événement même avec sa bonne note', () {
        runSong((async) {
          //arrange
          playAt(async, ms(4000), [e4, c3, g3]);

          //act
          playAt(async, ms(4500), [d4]);

          //assert
          expect(readRunning().judgedVerdicts[1]!.isCorrect, isFalse);
          expect(readRunning().judgedVerdicts[1]!.treble.isCorrect, isFalse);
          expect(readRunning().judgedVerdicts[1]!.bass.isCorrect, isTrue);
        });
      });

      test('compte faux le prochain événement encore ouvert', () {
        runSong((async) {
          //arrange
          playAt(async, ms(4000), [e4, c3, g3]);

          //act
          playAt(async, ms(4500), [c4]);
          playAt(async, ms(5000), [d4]);

          //assert
          expect(readRunning().judgedVerdicts[1]!.isCorrect, isFalse);
          expect(readRunning().errorCount, 1);
        });
      });
    });

    group('une main', () {
      test(
        'ne juge pas les événements de l\'autre main et compte fausse une touche de l\'autre main',
        () {
          runSong(hands: HandSelection.rightOnly, (async) {
            //arrange
            playAt(async, ms(4000), [c3, e4]);
            playAt(async, ms(5000), [d4]);
            playAt(async, ms(5500), [c4]);
            playAt(async, ms(10000), [c4]);

            //act
            elapseUntil(async, ms(11000));
            final sut = readRunning();

            //assert
            expect(sut.judgedVerdicts.keys, unorderedEquals([0, 1, 2, 4]));
            expect(sut.judgedVerdicts[0]!.isCorrect, isFalse);
            expect(sut.errorCount, 1);
          });
        },
      );
    });

    group('section', () {
      test('part du premier événement de la première mesure choisie', () {
        runSong(
          section: const SongSection(
            firstMeasureNumber: 2,
            lastMeasureNumber: 2,
          ),
          (async) {
            //arrange
            //act
            playAt(async, ms(4000), [g3]);

            //assert
            expect(readRunning().judgedVerdicts.keys, [3]);
            expect(readRunning().judgedVerdicts[3]!.isCorrect, isTrue);
          },
        );
      });

      test(
        'affiche la reprise au bout de la dernière mesure, avec les événements ratés',
        () {
          runSong((async) {
            //arrange
            playAt(async, ms(4000), [e4, c3, g3]);
            elapseUntil(async, ms(11999));
            final stateBeforeEnd = readState();

            //act
            elapseUntil(async, ms(12000));

            //assert
            expect(stateBeforeEnd, isA<SongTempoPlayRunning>());
            expect(readState(), const SongTempoPlayRetrying(errorCount: 4));
          });
        },
      );

      test('reprend du décompte après le message, couleurs effacées', () {
        runSong((async) {
          //arrange
          elapseUntil(async, ms(12000));

          //act
          async.elapse(sectionRetryDelay);
          final sut = readRunning();

          //assert
          expect(sut.judgedVerdicts, isEmpty);
          expect(sut.errorCount, 0);
          expect(readNotifier().elapsed, Duration.zero);
          playAt(async, ms(12000) + sectionRetryDelay + ms(4000), [e4, c3, g3]);
          expect(readRunning().judgedVerdicts[0]!.isCorrect, isTrue);
        });
      });
    });

    group('clavier débranché', () {
      test(
        'ignore les touches et ne ferme aucune fenêtre pendant la pause',
        () {
          runSong((async) {
            //arrange
            elapseUntil(async, ms(3000));
            readNotifier().pause();

            //act
            playAt(async, ms(4000), [e4, c3, g3]);
            elapseUntil(async, ms(20000));

            //assert
            expect(readRunning().judgedVerdicts, isEmpty);
            expect(readNotifier().elapsed, ms(3000));
          });
        },
      );

      test('repart du décompte au rebranchement, couleurs effacées', () {
        runSong((async) {
          //arrange
          playAt(async, ms(4000), [e4]);
          elapseUntil(async, ms(4500));
          readNotifier().pause();
          elapseUntil(async, ms(9000));

          //act
          readNotifier().resume();

          //assert
          expect(readRunning().judgedVerdicts, isEmpty);
          expect(readRunning().errorCount, 0);
          expect(readNotifier().elapsed, Duration.zero);
          playAt(async, ms(13000), [e4, c3, g3]);
          expect(readRunning().judgedVerdicts[0]!.isCorrect, isTrue);
        });
      });
    });
  });
}
