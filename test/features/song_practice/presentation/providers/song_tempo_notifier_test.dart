import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:key_starter/features/song_practice/presentation/providers/song_tempo_notifier.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());

  tearDown(() => container.dispose());

  SongTempoNotifier sut() => container.read(songTempoProvider.notifier);

  group('SongTempoNotifier', () {
    group('build', () {
      test('démarre à 60 BPM', () {
        //arrange
        //act
        final bpm = container.read(songTempoProvider);

        //assert
        expect(bpm, 60);
      });
    });

    group('increment', () {
      test('augmente de 5 BPM', () {
        //arrange
        //act
        sut().increment();

        //assert
        expect(container.read(songTempoProvider), 65);
      });

      test('ne dépasse pas 120 BPM', () {
        //arrange
        for (var step = 0; step < 20; step++) {
          sut().increment();
        }

        //act
        sut().increment();

        //assert
        expect(container.read(songTempoProvider), 120);
      });

      test('passe de Libre à 40 BPM', () {
        //arrange
        for (var step = 0; step < 5; step++) {
          sut().decrement();
        }

        //act
        sut().increment();

        //assert
        expect(container.read(songTempoProvider), 40);
      });
    });

    group('decrement', () {
      test('diminue de 5 BPM', () {
        //arrange
        //act
        sut().decrement();

        //assert
        expect(container.read(songTempoProvider), 55);
      });

      test('passe de 40 BPM à Libre', () {
        //arrange
        for (var step = 0; step < 4; step++) {
          sut().decrement();
        }

        //act
        sut().decrement();

        //assert
        expect(container.read(songTempoProvider), isNull);
      });

      test('reste sur Libre', () {
        //arrange
        for (var step = 0; step < 5; step++) {
          sut().decrement();
        }

        //act
        sut().decrement();

        //assert
        expect(container.read(songTempoProvider), isNull);
      });
    });
  });
}
