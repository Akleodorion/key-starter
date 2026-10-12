import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/core/enums/note_state.dart';
import 'package:key_starter/core/input/input_source_provider.dart';
import 'package:key_starter/core/utils/note_feedback_motion.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_chart.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_chart_bar.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_chart_cell.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_quality.dart';
import 'package:key_starter/features/chord_chart/domain/entities/chord_symbol.dart';
import 'package:key_starter/features/chord_chart/domain/entities/note_letter.dart';
import 'package:key_starter/features/chord_chart/domain/entities/spelled_note.dart';
import 'package:key_starter/features/chord_chart/presentation/providers/chord_chart_play_notifier.dart';
import 'package:key_starter/features/chord_chart/presentation/providers/chord_chart_play_state.dart';

import '../../../../core/input/fake_input_source.dart';

const f3 = 53;
const a3 = 57;
const c4 = 60;
const d4 = 62;
const e4 = 64;
const g4 = 67;
const c5 = 72;

ChordChartBar wholeBar(NoteLetter root) => ChordChartBar(
  cells: [
    ChordChartCell(
      chord: ChordSymbol(root: SpelledNote(root), quality: ChordQuality.major),
      beats: 4,
    ),
  ],
);

/// Deux mesures : Do majeur puis Fa majeur.
final chart = ChordChart(
  title: 'Essai',
  beatsPerBar: 4,
  bars: [wholeBar(NoteLetter.c), wholeBar(NoteLetter.f)],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeInputSource inputSource;
  late ProviderContainer container;

  // Appelé dans fakeAsync : le notifier doit naître dans la zone simulée
  // pour que ses timers suivent l'horloge du test.
  void startChart() {
    inputSource = FakeInputSource();
    container = ProviderContainer(
      overrides: [inputSourceProvider.overrideWithValue(inputSource)],
    );
    addTearDown(container.dispose);
    container.listen(chordChartPlayProvider(chart), (_, _) {});
  }

  ChordChartPlayState readState() =>
      container.read(chordChartPlayProvider(chart));

  ChordChartPlayRunning readRunning() => readState() as ChordChartPlayRunning;

  void playAndRelease(List<int> midiNumbers) {
    midiNumbers.forEach(inputSource.play);
    midiNumbers.forEach(inputSource.release);
  }

  group('ChordChartPlayNotifier', () {
    group('build', () {
      test('démarre sur la première case, sans résultat', () {
        fakeAsync((async) {
          //arrange
          //act
          startChart();
          final sut = readRunning();

          //assert
          expect(sut.currentCellIndex, 0);
          expect(sut.cellState, NoteState.idle);
          expect(sut.cellResults, isEmpty);
          expect(sut.errorCount, 0);
        });
      });
    });

    group('jugement', () {
      test('passe la case au vert dès que l\'accord est tenu', () {
        fakeAsync((async) {
          //arrange
          startChart();

          //act
          [c4, e4, g4].forEach(inputSource.play);
          final sut = readRunning();

          //assert
          expect(sut.cellState, NoteState.correct);
          expect(sut.cellResults, {0: true});
          expect(sut.errorCount, 0);
        });
      });

      test('passe la case au rouge dès qu\'une note étrangère est jouée', () {
        fakeAsync((async) {
          //arrange
          startChart();

          //act
          [c4, d4].forEach(inputSource.play);
          final sut = readRunning();

          //assert
          expect(sut.cellState, NoteState.wrong);
          expect(sut.cellResults, {0: false});
          expect(sut.errorCount, 1);
        });
      });

      test(
        'passe la case au rouge quand tout est relâché avant l\'accord complet',
        () {
          fakeAsync((async) {
            //arrange
            startChart();

            //act
            playAndRelease([c4, e4]);
            final sut = readRunning();

            //assert
            expect(sut.cellState, NoteState.wrong);
          });
        },
      );

      test('ignore les touches jouées après le verdict de la case', () {
        fakeAsync((async) {
          //arrange
          startChart();
          [c4, e4, g4].forEach(inputSource.play);

          //act
          inputSource.play(d4);
          final sut = readRunning();

          //assert
          expect(sut.cellState, NoteState.correct);
          expect(sut.errorCount, 0);
        });
      });
    });

    group('enchaînement', () {
      test(
        'passe à la case suivante après l\'effet, même après une erreur',
        () {
          fakeAsync((async) {
            //arrange
            startChart();
            [c4, d4].forEach(inputSource.play);

            //act
            async.elapse(noteAdvanceDelay);
            final sut = readRunning();

            //assert
            expect(sut.currentCellIndex, 1);
            expect(sut.cellState, NoteState.idle);
            expect(sut.cellResults, {0: false});
          });
        },
      );

      test('ignore une touche encore tenue depuis la case précédente', () {
        fakeAsync((async) {
          //arrange
          startChart();
          [c4, e4, g4].forEach(inputSource.play);
          async.elapse(noteAdvanceDelay);

          //act
          [f3, a3, c5].forEach(inputSource.play);
          final sut = readRunning();

          //assert
          expect(sut.cellState, NoteState.correct);
          expect(sut.cellResults, {0: true, 1: true});
        });
      });
    });

    group('reprise', () {
      test('annonce la reprise avec le nombre d\'erreurs en fin de grille', () {
        fakeAsync((async) {
          //arrange
          startChart();
          playAndRelease([c4, d4]);
          async.elapse(noteAdvanceDelay);

          //act
          playAndRelease([f3, a3, c4]);
          async.elapse(noteAdvanceDelay);
          final sut = readState();

          //assert
          expect(sut, const ChordChartPlayRetrying(errorCount: 1));
        });
      });

      test('reprend la grille au début, résultats effacés', () {
        fakeAsync((async) {
          //arrange
          startChart();
          playAndRelease([c4, e4, g4]);
          async.elapse(noteAdvanceDelay);
          playAndRelease([f3, a3, c4]);
          async.elapse(noteAdvanceDelay);

          //act
          async.elapse(chordChartRetryDelay);
          final sut = readRunning();

          //assert
          expect(sut.currentCellIndex, 0);
          expect(sut.cellState, NoteState.idle);
          expect(sut.cellResults, isEmpty);
          expect(sut.errorCount, 0);
        });
      });
    });
  });
}
